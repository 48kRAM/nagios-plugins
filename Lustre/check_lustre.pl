#!/usr/bin/perl
#
# Nagios check plugin for lustre filesystems.
#
# Copyright (c) 2016 - Joshua Malone
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.
#

$revision=5;

use lib "/usr/lib64/nagios/plugins";
use lib "/usr/lib/nagios/plugins";
use lib ".";
use utils qw($TIMEOUT %ERRORS &print_revision &support);
use Switch;
use Getopt::Long;

$exstate=$ERRORS{'OK'};
$message="OK: All filesystems okay";
%pctused=();
%bused=();
%btotal=();

$warnpct=70;
$critpct=85;

##########

GetOptions(
    "f|filesystem=s"	=> \$opt_f,
    "p|pool=s"		=> \$opt_p,
    "w|warning=i"	=> \$warnpct,
    "c|critical=i"	=> \$critpct,
    "h|help"		=> \$opt_h,
    "t|ignore-unavailable"	=> \$opt_t,
    "l|log"		=> \$logfile,
    "v|verbose"		=> \$verbose,
    "V|version"		=> \$print_version,
    "s"			=> \$opt_s,
    "i|ignore-ost=s"	=> \@ignore_osts,
    "ignore-regex=s"	=> \$ignore_regex,
);

# Convert the list of ignored OSTs into a hash
%ignore_these = map { $_ => 1 } @ignore_osts;

# Build regex to ignore
if ($ignore_regex) {
    $ignore_match = qr/$ignore_regex/;
}

if ($opt_v) {
    printf("check_lustre.pl, by jmalone\@nrao.edu, version %d\n", $revision);
    exit 0;
}
if ($opt_h) {
    # Help message
    print << "EOHELP";
Usage:  check_lustre.pl [-tvVh] [-f <fs>] [-p <pool>]  [-w <warn>] [-c <crit>] [-l <logfile>]

	-f: Only check a single lustre filesystem
	-p: Only check a single lustre pool
	-w: Warning space threshold (percent used)
	-c: Critical space threshold (percent used)
	-t: Ignore OSTs that are temporarily unavailable
	-l: Write debug log information to file
	-V: Print version information
	-v: Print verbose progress information
	-h: Print this help message

	-i|--ignore-ost:  Ignore problems with a specific OST
	--ignore-regex:   Ignore OSTs matching given regular expression

EOHELP
    exit 0;
}
if ($logfile) {
    open(LOG, ">>", $logfile) or die ("Unable to open logfile $logfile\n");
}
print LOG "Starting check_lustre.pl at ".localtime()."\n" if ($logfile);

# Set alarm to time out possibly hung `lfs df` command
alarm 40;
$SIG{ALRM} = sub {
    print LOG "CRITICAL - check_lustre.pl quit after ALARM at ".localtime()."\n" if ($logfile);
    print "CRITICAL: lustre lfs operation timed out\n";
    exit $ERRORS{'CRITICAL'};
};

# Make sure lustre FS is loaded and available
if ( ! -d "/proc/fs/lustre" ) {
    print("CRITICAL: lustre filesystem not available!\n");
    exit $ERRORS{'CRITICAL'};
}

print LOG "Checking /proc/fs/lustre/health_check at ".localtime()."\n" if ($logfile);
open (PROC, "/proc/fs/lustre/health_check") or die("Cannot read lustre health_check - is lustre installed?");
while(<PROC>) {
    chomp();
    if ($_ ne "healthy") {
    	$message="CRITICAL: Lustre not healthy";
	$exstate=$ERRORS{'CRITICAL'};
    }
}
close (PROC);
print LOG "Proc check completed at ".localtime()."\n" if ($logfile);

##################################################

if ($opt_p) {
    # Check specific lustre pool
    $lfsopts="df -p $opt_p";
} else {
    $lfsopts="df";
}
if ($opt_s) {
    open (LFS, "-") 
} else {
    open (LFS, "lfs $lfsopts |") or die("Cannot read from lfs!");
}
while (<LFS>) {
    chomp();
    @parts=split(' ');
    # Check to see if we should ignore this particular ost
    next if ( $ignore_these{$parts[0]} );
    if ( /unavailable/ ) {
        if ( $opt_t && /Resource temporarily unavailable/) {
	    next;
	} elsif ( $ignore_regex && $parts[0] =~ $ignore_match) {
	    next;
	} else {
	    $exstate=$ERRORS{'CRITICAL'};
	    $message="CRITICAL: ".join(' ',@parts);
	}
    } elsif ( /filesystem summary/) {
	if (!$opt_f || $_ =~ /$opt_f$/) {
	    break if ($opt_p && ($parts[4]==0) );
	    $fs=$parts[6];
	    $fs=~s/.*\///;
	    $btotal{$fs}=$parts[2]*1024;
	    $bused{$fs}=$parts[3]*1024;
	    $tmp=$parts[5];
	    $tmp=~s/\%//;
	    $pctused{$fs}=$parts[5];
	    if ($parts[5] > $critpct) {
		# Don't overwrite a more serious OST error
		if( $exstate <= $ERRORS{'WARNING'} ) {
		    $message=sprintf("CRITICAL: Filesystem %s is %d%% full", $fs, $parts[5]);
		    $exstate=$ERRORS{'CRITICAL'};
		}
	    }
	    if ($parts[5] > $warnpct) {
		if( $exstate==$ERRORS{'OK'} ) {
		    $message=sprintf("WARNING: Filesystem %s is %d%% full", $fs, $parts[5]);
		    $exstate=$ERRORS{'WARNING'};
		}
	    }
	print LOG "FS summary at ".localtime()." - $_\n" if ($logfile);
	}
    }
}
$perf='';
foreach $fs (keys(%pctused)) {
    $perf.=sprintf(" %s_percent_used=%s;%d;%d", $fs, $pctused{$fs}, $warnpct, $critpct );
    $perf.=sprintf(" %s_used=%dBytes;%d;%d", $fs, $bused{$fs}, $btotal{$fs}*$warnpct, $btotal{$fs}*$critpct );
}
print $message;
print " |$perf" if ($perf);
print "\n";
exit $exstate;

close(LFS);
close(LOG);

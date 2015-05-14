#!/usr/bin/perl
#
# Nagios check plugin for lustre filesystems.
#
# Josh Malone (jmalone@nrao.edu) - July 2013
#
# Revision 3 - July 17, 2013
# Revision 4 - July 18, 2013

$revision=4;

use lib "/usr/lib64/nagios/plugins";
use lib "/usr/lib/nagios/plugins";
use lib ".";
use utils qw($TIMEOUT %ERRORS &print_revision &support);
use Switch;
use Getopt::Std;

$exstate=$ERRORS{'OK'};
$message="OK: All filesystems okay";
%pctused=();
%bused=();
%btotal=();

$warnpct=70;
$critpct=85;

##########

getopts('w:c:htsvf:l:p:d');
if ($opt_w) { $warnpct=$opt_w; }
if ($opt_c) { $critpct=$opt_c; }

if ($opt_v) {
    printf("check_lustre.pl, by jmalone\@nrao.edu, version %d\n", $revision);
    exit 0;
}
if ($opt_h) {
    # Help message
    print << "EOHELP";
Usage:  check_lustre.pl [-tvh] [-f <fs>] [-p <pool>]  [-w <warn>] [-c <crit>] [-l <logfile>]

	-f: Only check a single lustre filesystem
	-p: Only check a single lustre pool
	-w: Warning space threshold (percent used)
	-c: Critical space threshold (percent used)
	-t: Ignore OSTs that are temporarily unavailable
	-l: Write debug log information to file
	-v: Print version information
	-h: Print this help message
EOHELP
    exit 0;
}
if ($opt_l) {
    open(LOG, ">>", $opt_l) or die ("Unable to open logfile $opt_l\n");
}
print LOG "Starting check_lustre.pl at ".localtime()."\n" if ($opt_l);

# Set alarm to time out possibly hung `lfs df` command
alarm 40;
$SIG{ALRM} = sub {
    print LOG "CRITICAL - check_lustre.pl quit after ALARM at ".localtime()."\n" if ($opt_l);
    print "CRITICAL: lustre lfs operation timed out\n";
    exit $ERRORS{'CRITICAL'};
};

# Make sure lustre FS is loaded and available
if ( ! -d "/proc/fs/lustre" ) {
    print("CRITICAL: lustre filesystem not available!\n");
    exit $ERRORS{'CRITICAL'};
}

print LOG "Checking /proc/fs/lustre/health_check at ".localtime()."\n" if ($opt_l);
open (PROC, "/proc/fs/lustre/health_check") or die("Cannot read lustre health_check - is lustre installed?");
while(<PROC>) {
    chomp();
    if ($_ ne "healthy") {
    	$message="CRITICAL: Lustre not healthy";
	$exstate=$ERRORS{'CRITICAL'};
    }
}
close (PROC);
print LOG "Proc check completed at ".localtime()."\n" if ($opt_l);

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
    switch ($_) {
	case /Resource temporarily unavailable/ {
		next unless ($opt_t);
	}
	case /unavailable/ {
		$exstate=$ERRORS{'CRITICAL'};
		$message="CRITICAL: ".join(' ',@parts);
	}
	case /filesystem summary/ {
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
			if( $exstate==$ERRORS{'OK'} ) {
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
		print LOG "FS summary at ".localtime()." - $_\n" if ($opt_l);
		}
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

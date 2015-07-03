#!/usr/bin/perl -w
# nagios: -epn
#
# Perl template for a Nagios check plugin.
#
# This template can be used as a starting point for writing your own custom
# check plugins for Nagios/Icinga/Shinken/etc. This template provides
# command-line parsing, exit status, perfdata output, etc.
#
#
# Copyright 2015 Joshua Malone <jmalone@nrao.edu>
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
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

# These lines include the Nagios-provided exit code perl module.
# You may need to adjust the location of your included lib directory.
use lib qw ( . /usr/lib/nagios/libexec );
use utils qw(%ERRORS);

# Uncomment this line to use the Net::SNMP library
#use Net::SNMP;
use Getopt::Long qw(:config no_ignore_case);

# Set the name of your plugin script here. This will be used
# in the help and version output.
$PROGNAME="name_of_plugin";

# Enter the version number of your plugin here. Remember to
# increment this version each time your release or commit it.
# You can use integers or real numbers (x.y) as you please.
$VERSION=1;

# Your name - used in version output
$AUTHOR_NAME='My Name';

# Your email address or other info string. Be sure to use
# single-quotes so that perl doesn't interpret an email address
# as an array.
$AUTHOR_INFO='user@example.com';

# Help function.
# This function is called to provide usage information to the user
# either when asked for via --help or -h or when an illegal option
# is given on the command line. Be sure to add any additional options
# that you use in your plugin to this output.
sub print_help () {
    my $help = << "EOH";
Usage: $PROGNAME -H <host address> -w <warning> -c <critical> [-vV]

    -H, --host		Hostname or IP address of host to check
    			(Usually \$HOSTADDRESS\$ in Nagios)
    -w, --warning	Warning threshold (supports Nagios range syntax)
    -c, --critical	Critical threshold (supports Nagios range syntax)
    -v, --verbose	Print verbose debugging output
    -V, --version	Print the plugin version and exit

EOH
    print ($help);
    exit $ERRORS{'UNKNOWN'};
}

### Set some defaults
#
# Default status is 'OK'. Change the status if any threshold is exceeded.
# Note: This logic may or may not work for your plugin. Change this line
# if your plugin logic works differently.
$status='OK';

# You can also define some default thresholds if there are logical defaults
# for you application (disk usage at 90%, room temperature above 75F, etc.)
# These will be overridden by values on the command line (parsed below).
#
# $warn = '80';
# $crit = '90';

# Series label for performance data output. Should reflect what is being
# measured in the perfdata as it will be shown in the graphs
$perfLabel='label';
$perfUnit='suffix';

GetOptions(
    "H|host=s"		=> \$hostaddress,
    "h|help"		=> \$helpMe,
    "w|warning=s"	=> \$warn,
    "c|critical=s"	=> \$crit,
    "v|verbose"		=> \$debug,
    "V|version"		=> \$doVersion,
) or print_help();

if ($doVersion) {
    printf("%s by %s (%s) version %d\n", $PROGNAME, $AUTHOR_NAME, $AUTHOR_INFO, $VERSION);
    exit $ERRORS{'UNKNOWN'};
}
if ($helpMe) {
    # This call exits automatically.
    print_help();
}

### Parse threshold ranges in Nagios range syntax.
# https://nagios-plugins.org/doc/guidelines.html#THRESHOLDFORMAT
#
# Currently, this template only supports "outside the range" syntax
# and does not support the use of ~ for infinity. To-do!
@Warn=split(':', $warn) if (defined($warn));
@Crit=split(':', $crit) if (defined($crit));
if(scalar(@Warn) > 1) {
    printf("Checking low and high warning thresholds\n") if ($debug);
    ($warnLow, $warn)=@Warn;
}
if(scalar(@Crit) > 1) {
    printf("Checking low and high critical thresholds\n") if ($debug);
    ($critLow, $crit)=@Crit;
}
printf("Thresholds in use: W->%d:%d , C->%d:%d\n", $warnLow, $warn, $critLow, $crit) if ($debug);

##########  Write your plugin logic below this line  #############

=pod

Your plugin should now do it's work to perfom some check and compare
the state of some service or metric to the warning and critical
thresholds. If your check does not use numeric thresholds, then the
$warn and $crit values can jus be ignored in the template.

Your check logic should set the following variables:

  $status = The textual status of the service (OK, WARNING, etc.)
  $info = Additional info about the state of the service - used
          in the Screen output

You *MUST* place your code outside the =pod and =cut lines so that
Perl actually runs the code for your service check.

=cut

# The $status variable should get set to a proper Nagios status code:
#   'OK', 'WARNING', 'CRITICAL' or 'UNKNOWN'
$status="UNKNOWN";

# The $info variable should report a short human readable summary
$info="This is just a plugin template and does no actual checks";

# The $perfValue variable can be set to some metric to be reported as
# performance data (perfdata). If your plugin has no metrics to be
# reported, leave $perfValue undefined
#
# $perfValue=42;

#############  End of your plugin logic  ##############

# The Screen output should always begin with the readable status value
# ('OK', 'WARNING', 'CRITICAL' or 'UNKNOWN')
$outstring="$status: $info";

if(defined($perfValue)) {
    # Compile the performance data. If threshold ranges are in use, format
    # the thresholds in perfdata range format as well.
    if(defined($critLow)) {
	$perfWarnCrit=sprintf("%d:%d;%d:%d", $warnLow, $warn, $critLow, $crit);
    } else {
	$perfWarnCrit=sprintf("%d;%d", $warn, $crit);
    }
    $perfData=sprintf("|%s=%d%s;%s", $perfLabel, $perfValue, $perfUnit, $perfWarnCrit);
}

if(defined($perfValue)) {
    # Concatenate the Screen Ouput and perfdata to stdout so that Nagios can grab it.
    print "$outstring$perfData\n";
} else {
    print "$outstring\n";
}

# Exit with the status exit code appropriate to the textual status.
exit $ERRORS{$status};

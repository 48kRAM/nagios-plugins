# check_lustre.pl

Simple check plugin to monitor the health and filesystem size of one or more lustre filesystems.

This check must be run on a system that mounts the monitored lustre filesystems. Uses 'lfs df' to gather info on filesystems so it should not use any costly (in terms of performance) commands. Outputs performance data for filesystem size graphing. Graphs both utilization and space used.
This is a simple check plugin to monitor the health and filesystem size of one or more lustre filesystems. This check must be run on a system that mounts the monitored lustre filesystems. Use NRPE to execute it as a remote check.

This plugin uses lfs df to gather info on filesystems so it should not use any costly (in terms of performance) commands like ls, etc. In addition, it also outputs performance data so you can get pretty graphs of filesystem size (bytes) and utilization (percent). Also uses an alarm to detect if the 'lfs' call is hanging.

Rev 3: Added '-t' option to ignore OSTs that are temporarily unavailable (such as IDs reserved for future use)

You must have nagios-plugins installed on the lustre host as this plugin requires utils.pm.

This plugin has shown to be stable and helpful in our environment. This plugin has been tested on lustre 1.8.9 and 2.3.0 at this point; if your output of lfs df is different somehow you may receive false alarms.

Tested using perl 5.8 and perl 5.12.


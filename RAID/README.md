# check_areca

Check plugin for Areca RAID controller. Checks RAID sets, volumes, controller info and (optionally) disks.

Note: This plugin was developed against an ARC-1882 controller running
Areca CLI, Version: 1.13.0, Arclib: 343, Date: Oct 29 2013( Linux ). 
I've done my best to reference available documentation as well as other posted CLI output.
Other OS versions, CLI versions, etc. may cause this plugin to misbehave. Patches appreciated.

### Requirements

This plugin should run on most typical perl installations that provide:

* perl 5.8 or higher
* Some perl modules
  * Getopt::Long
* utils.pm from Nagios package

### Usage

    check_areca [options]

**Optional arguments**

    -C, --cli-path      Full path to the Areca cli
    -w, --warning       Disk temperature warning threshold (C)
    -c, --critical      Disk temperature critical threshold (C)
    --cpu-warn          CPU temperature warning threshold (C)
    --cpu-crit          CPU temperature critical threshold (C)
    --check-disks       Perform deep check of disk status (longer run-time)
    --timeout		Change default plugin timeout (default 40 sec)
    -v, --verbose       Print verbose debugging output
    -V, --version       Print the plugin version and exit
    -h, --help          Print this help text

Note: Temperature thresholds are upper thresholds only. Ranges are not supported.

---
This project is *not* associated with Areca Technology Corp.

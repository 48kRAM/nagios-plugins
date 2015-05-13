# check_apc_temp

Check plugin to read an integrated temperature probe on an APC Smart UPS

This plugin will read the temperature and system (F or C) from an integrated temperature monitoring probe on a networked APC Smart UPS. I have tested it work with SmartUPS rackmount units and Symmetra datacenter systems.

### Requirements

This plugin should run on most typical perl installations that provide:

* perl 5.8 or higher
* Net::SNMP
* Getopt::Long
* utils.pm from Nagios package

### Usage

    check_apc_temp -H <hostaddress> -C <community> [-p <probe number>] -w <warn> -c <critical>

**Mandatory arguments**

    -H, --host          Host address ($HOSTADDRESS$ frrom Nagios)
    -w, --warning       Warning threshold
    -c, --critical      Critical threshold

**Optional arguments**

    -C, --community     SNMP community string (defaults to 'public')
    -p, --probe         Probe number (defaults to 1)
    -v, --verbose       Verbose/debugging output

Both the warning and critical thresholds support Nagios range syntax for high and low thresholds. The performance data automatically uses the proper temperature system.

---
APC and Symmetra are registered trademarks of American Power Conversion Corporation. This project is *not* affilliated with American Power Conversion Corporation.

# check_ims_sensor

Check plugin to pull environment sensor data from a Sensaphone(tm) IMS-4000(tm) monitoring system.

This plugin will query an input channel for type, label and value and provide screen output based on the channel's configuration on the IMS-4000. Currently supported sensor types are:

* Temperature (C or F)
* Sound, usually from internal mic (dB)
* Power input (0 or 1, 0 is normal)
* Humidity (% relative humidity)
* Water sensor (0 or 1)
* N.O. Dry contact (0 or 1)

### Requirements

This plugin should run on most typical perl installations that provide:

* perl 5.8 or higher
* Net::SNMP
* Getopt::Long
* utils.pm from Nagios package

### Usage

    check_ims_sensor -H <hostaddress> [-C <community>] [-n <node>] -I <input> [options]

**Mandatory arguments**

    -H, --host          Host address ($HOSTADDRESS$ frrom Nagios)
    -I, --input         Input channel number (starting from 1)

**Optional arguments**

    -C, --community     SNMP community string (defaults to 'public')
    -n, --node          Node number (Starts from 1; defaults to 0 for IMS Host)
    -w, --warning       Warning threshold
    -c, --critical      Critical threshold
    -v, --verbose       Verbose/debugging output
    -u, --unit          Override value unit string
    -t, --type          Override input type string
    --list-sensors	List available sensors on the selected node

Both the warning and critical thresholds support Nagios range syntax for high and low thresholds. The string overrides are only used in the screen output of the Nagios plugin. The performance data automatically uses the input channel's proper unit and type; this prevents RRD series from changing if you change a channel label in IMS.

### Using sensors

**Dry contacts**

This plugin currently only supports normally-open (N.O.) dry contacts (that's all I have). An N.O. input is automatially assumed to be in 'OK' state when open and 'CRITICAL' state when closed.

---
Sensaphone and IMS-4000 are registered trademarks of Phonetics Incorporated. This project is *not* affilliated with Phonetics Incorporated.

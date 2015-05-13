# check_ims_sensor

Check plugin to pull environment sensor data from a Sensaphone(tm) IMS-4000 monitoring system.

### Usage

    check_ims_sensor -H <hostaddress> [-C <community>] [-n <node>] -I <input> [options]

*Mandatory arguments*

    -I    Input channel number (starting from 1)
    -H    Host address ($HOSTADDRESS$ frrom Nagios)

*Optional arguments*

    -C    SNMP community string (defaults to 'public')
    -n    Node number (Starts from 1; defaults to 0 for IMS Host)
    -w    Warning threshold
    -c    Critical threshold

Both the warning and critical thresholds support Nagios range syntax for high and low thresholds.



---
Sensaphone and IMS-4000 are registered trademarks of Phonetics Incorporated. This project is *not* affilliated with Phonetics Incorporated.

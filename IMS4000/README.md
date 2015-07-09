# check\_ims_sensor

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
* Some perl modules
  * Net::SNMP
  * Math::Round
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
    -s, --system        Force output to temperature system (F or C)
    -v, --verbose       Verbose/debugging output
    -u, --unit          Override value unit string
    -t, --type          Override input type string

    --list-sensors      List available sensors on the selected node

Both the warning and critical thresholds support Nagios range syntax for high and low thresholds. The string overrides are only used in the screen output of the Nagios plugin. The performance data automatically uses the input channel's proper unit and type; this prevents RRD series from changing if you change a channel label in IMS.

### Listing available sensors

Pass the `--list-sensors` option to query your IMS for a list of connected sensors. Expected output should look something like this:

```
Available sensors:
  Ch 1: Type temp, Name: Temperature
  Ch 2: Type smoke, Name: Smoke Detector
  Ch 3: Type smoke, Name: Smoke Detector
  Ch 4: Type water, Name: Raised Floor Water Sensor
  Ch 5: Not connected
  Ch 6: Not connected
  Ch 7: Not connected
  Ch 8: Type N.O. contact, Name: Fire Alarm
  Ch 9: Type battery, Name: Battery
  Ch 10: Type hostPower, Name: Power
  Ch 11: Type sound, Name: High Sound

```

(Verbose mode adds the numeric sensor types to this output)

### Thresholds

If a critical threshold is not provided on the command line, `check_ims_sensor` will attempt to use the critical high-value threshold configured on the IMS itself. This configured threshold is reported when the plugin is run in verbose mode.

This plugin has built-in warning thresholds for sound and temperature.

Some sensors, such as water, power and contacts, are only binary (yes/no) sensors, so there is no WARNING state for these sensors. The critical state is built-in and cannot be overridden.

### Using sensors

**Temperature sensors**

IMS temperature sensors report their temerature system - Farenheit or Celsius. You can force this plugin to convert to your desired temeprature system with the -s (--system) option. Valid systems are 'F' and 'C'.

**Dry contacts**

This plugin currently only supports normally-open (N.O.) dry contacts (that's all I have). An N.O. input is automatially assumed to be in 'OK' state when open and 'CRITICAL' state when closed.

---
Sensaphone and IMS-4000 are registered trademarks of Phonetics Incorporated. This project is *not* affilliated with Phonetics Incorporated.

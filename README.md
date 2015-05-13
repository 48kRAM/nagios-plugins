# nagios-plugins
Plugins for Nagios monitoring framework (and compatibles)

This is my collection of check plug-ins written for the Nagios monitoring package. (www.nagios.org). They should work with Nagios-compatible moitoring software as well (Icinga, Shinken, Naemon, etc.) but I have not and probably will not test against anything but Nagios 4.x.

## Plugins

### IMS4000/check_ims_sensor

The Sensaphone IMS-4000 is a standalone environment monitoring server. While the IMS-4000 is capable of monitoring and alerting all on its own, this plugin allows Nagios to pull data from sensors attached to an IMS-4000 so you can add the extended graphing and alerting capbilities of Nagios to your IMS-4000.
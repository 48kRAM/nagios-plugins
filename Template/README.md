# check_template

Template for a Nagios check plugin written in Perl.

### Requirements

This plugin should run on most typical perl installations that provide:

* perl 5.8 or higher
* Getopt::Long
* utils.pm from Nagios package

### How to use this template

This template includes my framework for parsing command line options, setting
some useful defaults, handling threshold ranges and formatting the screeen and
perfdata (Performance data) output. Simply add the logic for your particular
service check in indicated place in this template.

Comes with command-line option handling for:

  -H (host address)
  -w (warning)
  -c (critical)
  -h (help output)
  -V (version output)

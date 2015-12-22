# check\_dns_data

Nagios plugin to check DNS zones and records against known-good data.

This plugin will query a DNS name server for a series of zones and records and compare the answers to configured, known-good answers. This plugin may be used to verify that a zone is being served correctly or that certain well-known records are being answered for properly (i.e., no DNS spoofing is being done by an upstream server).

## Requirements

This plugin was developed and tested on Red Hat Enterprise Linux 6.x. It may function properly on other systems that provide:

* perl 5.8 or higher
* Perl modules:
  * Net::DNS
  * Getopt::Long
* utils.pm (from Nagios package)

**Perl Version Warning**

The DNS::RR tsig code has changed completely since the version included with RHEL6. Distributions that include perl 5.10 and beyond will probably NOT be able to use the TSIG key functionality properly without midifications. PLEASE PLEASE PLEASE submit changes if you figure out how to make this work on other distributions.

## Usage

    check_dns_data -c <config file> [-H <host address>] [-v] [-V]

**Mandatory arguments**

    -c, --config    /path/to/config.file

**Optional arguments**

    -H, --host      DNS server host to query
    --nokeys        Do not use TSIG keys during the check,
                    even if given in the config file
    -v, --verbose   Display verbose output
                    (Can be given multiple times)
    -V, --version   Display plugin version

## Config file syntax

This plugin is designed to check multiple zones and multiple records in a single invocation, so it would be impractical to configure it on the command line. This plugin expects a config file with instructions on what to check. Note: some aspects of the check behaviour can be altered on the command line (e.g., --nokeys)

`Check zone <zone>`

Checks that the server responds for a given DNS zone. All subsequent config lines refer to this zone until a new "Check zone" statement is given. An individual zone can be specified more than once in a single config file if needed (i.e., to check multiple views).

`Use key <keyname> TSIG <key data>`

Use the given TSIG key when querying in this zone. Can be used for restricted zones or to specify a specific view of a zone. The key must be properly configured on the name server to have the desired effect.

`Record <foo> should be <bar>`

Check that the record 'foo', in the selected zone, resolves to the string 'bar'. If a record has a connonical name (CNAME), the plugin will match either the CNAME or the target A record; both will be considered 'OK'.

`Record <foo> should exist`

Check that a valid answer is given for the record 'foo' but do not be concerned about the value of the answer. Use when you just want to make sure a record exists but you don't care what it is.

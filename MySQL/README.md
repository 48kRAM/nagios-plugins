# check\_mysql_rep

Check plugin to query the status of a MySQL replication slave.

This plugin will establish a MySQL connection to a server and check the replication slave status. Current metrics checked are:

 * Last\_Errno (Last error encountered)
 * Seconds\_Behind_Master (Slave replication delay)

### Requirements

This plugin should run on most typical perl installations that provide:

 * perl 5.8 or higher
 * mysql command line monitor

### Usage

```
check_mysql_rep -H <hostaddress> -u <username> -p <password> [options]
```

**Mandatory arguments**

  -H, --host      MySQL server hostname/IP
  -u, --user      MySQL login username
  -p, --password  MySQL login password
  
**Optional arguments**

  -w, --warning   Delay warning threshold (seconds)
  -c, --critical  Delay critical threshold (seconds)

### Thresholds

The warning and critical thresholds set the number of seconds behind the master that the slave is allowed to run before triggering an alert.

---
MySQL is a trademark owned by Oracle Corporation Inc. This project is *not* affilliated with Oracle Corporation Inc.
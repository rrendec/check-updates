Run check\_updates asynchronously
=================================

This is a collection of scripts that implement a simple wrapper around the
[check\_updates Nagios plugin](https://github.com/matteocorti/check_updates).
It aims to move the time/resource consuming execution of the check\_updates
plugin out of the context of Nagios or nrpe.

The wrapper implements a systemd service that runs the real check\_updates
plugin periodically and saves the output and exit status to a cache file.
A new/separate Nagios plugin is implemented as a shell script that simply
reads back the output from the cache file.

This approach solves the following problems of running the check\_updates
plugin directly:
  - The plugin is likely to time out, especially on low-end systems, and
    would otherwise require explicit Nagios configuration to increase the
    timeout to an acceptable value.
  - The system has constant load spikes, unless the Nagios service is
    specifically configured to run less often.

# Installation instructions

## Prerequisites

```shell
dnf install make tar
dnf install epel-release
crb enable
dnf install nrpe nagios-plugins-check-updates
```

If SELinux is configured (see below):
```shell
dnf install checkpolicy policycoreutils-python-utils
```

## Installation

```shell
make install
```

## SELinux configuration

```
make local.pp
# or:
#   dnf install selinux-policy-devel
#   make -f /usr/share/selinux/devel/Makefile local.pp
semodule -i local.pp
semanage fcontext -a -t nrpe_cache_t '/var/cache/nrpe(/.*)?'
restorecon -R /var/cache/nrpe
```

# Usage

Use the systemd `reload` action to force the real check\_updates to run.

## Sample nrpe configuration

Add the following line to `/etc/nagios/nrpe.cfg`:

```
command[check_updates]=/usr/lib64/nagios/plugins/check_updates_cached
```

## For containers

Edit `/etc/sysconfig/check-updates` and add the following option to `OPTS`:

```
--no-boot-check
```

This option disables the kernel check, since the kernel package is typically not
installed inside containers.

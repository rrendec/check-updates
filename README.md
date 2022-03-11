Run check\_updates asynchronously
=================================

This is a collection of scripts that implement a simple wrapper around the
[check\_updates Nagios plugin](https://github.com/matteocorti/check_updates).
It aims to move the time/resource consuming execution of the check\_updates
plugin out of the context of Nagios or nrpe.

The wapper implements a systemd service that runs the real check\_updates
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

```shell
mkdir -p /var/cache/nrpe
chmod 700 /var/cache/nrpe
chown nrpe: /var/cache/nrpe
cp -f check_updates_daemon /usr/local/bin
cp -f check_updates_cached /usr/lib64/nagios/plugins
mkdir -p /usr/local/lib/systemd/system
cp -f check-updates.service /usr/local/lib/systemd/system
systemctl daemon-reload
systemctl enable --now check-updates.service
```

# Usage

Use the systemd `reload` action to force the real check\_updates to run.

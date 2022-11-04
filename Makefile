.PHONY: install

install:
	mkdir -p /var/cache/nrpe
	chmod 700 /var/cache/nrpe
	chown nrpe: /var/cache/nrpe
	cp -f check_updates_daemon /usr/local/bin
	cp -f check_updates_cached /usr/lib64/nagios/plugins
	mkdir -p /usr/local/lib/systemd/system
	cp -f check-updates.service /usr/local/lib/systemd/system
	systemctl daemon-reload
	systemctl enable --now check-updates.service

%.mod: %.te
	checkmodule -M -m -o $@ $<

%.pp: %.mod
	semodule_package -o $@ -m $<

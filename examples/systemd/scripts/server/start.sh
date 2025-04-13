#!/bin/bash

# Set default variables
export INSTANCE="${INSTANCE:-${SYSTEMD_INSTANCE}}"

mkdir -p "/var/lib/spire/server/${SYSTEMD_INSTANCE}" "/run/spire/server/${SYSTEMD_INSTANCE}/private" "/etc/spire/server/${SYSTEMD_INSTANCE}/tpm-direct/certs" "/etc/spire/server/${SYSTEMD_INSTANCE}/tpm-direct/hashes"

if [ -f "/etc/spire/server/${SYSTEMD_INSTANCE}/config" ]; then
	cp -a "/etc/spire/server/${SYSTEMD_INSTANCE}/config" "/var/lib/spire/server/${SYSTEMD_INSTANCE}/config"
else
	if [ -f "/etc/spire/server/${SYSTEMD_INSTANCE}.conf" ]; then
		cp -a "/etc/spire/server/${SYSTEMD_INSTANCE}.conf" "/var/lib/spire/server/${SYSTEMD_INSTANCE}/config"
	else
		cp -a "/etc/spire/server/default.conf" "/var/lib/spire/server/${SYSTEMD_INSTANCE}/config"
	fi
fi

/bin/spire-server run -config "/var/lib/spire/server/${SYSTEMD_INSTANCE}/config" -dataDir "/var/lib/spire/server/${SYSTEMD_INSTANCE}" -socketPath "/run/spire/server/sockets/${SYSTEMD_INSTANCE}/private/api.sock" -expandEnv

#!/bin/bash

# Set default variables
export INSTANCE="${INSTANCE:-${SYSTEMD_INSTANCE}}"
export SCM_CLASSNAME="${SCM_CLASSNAME:-scm-${SYSTEMD_INSTANCE}}"
export SCM_ENTRYID_PREFIX="${SCM_ENTRYID_PREFIX:-${SCM_CLASSNAME}}"
export SCM_CLUSTERNAME="${SCM_CLUSTERNAME:-${SCM_CLASSNAME}}"

mkdir -p "/var/lib/spire/controller-manager/${SYSTEMD_INSTANCE}"

if [ -f "/etc/spire/controller-manager/${SYSTEMD_INSTANCE}.conf" ]; then
	cp -a "/etc/spire/controller-manager/${SYSTEMD_INSTANCE}.conf" "/var/lib/spire/controller-manager/${SYSTEMD_INSTANCE}/config"
else
	cp -a /etc/spire/controller-manager/default.conf "/var/lib/spire/controller-manager/${SYSTEMD_INSTANCE}/config"
fi

/bin/spire-controller-manager -config "/var/lib/spire/controller-manager/${SYSTEMD_INSTANCE}/config" -expand-env

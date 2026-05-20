#!/bin/bash

/bin/spire-agent run -config "/var/lib/spire/agent/${SYSTEMD_INSTANCE}/config" -dataDir "/var/lib/spire/agent/${SYSTEMD_INSTANCE}" -socketPath "/run/spire/agent/sockets/${SYSTEMD_INSTANCE}/public/api.sock" -expandEnv ${JOIN_TOKEN:+-joinToken="${JOIN_TOKEN}"}

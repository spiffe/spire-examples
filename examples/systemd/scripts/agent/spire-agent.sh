#!/bin/bash

export SPIRE_AGENT_PUBLIC_SOCKET="${SPIRE_AGENT_PUBLIC_SOCKET:-/run/spire/agent/sockets/main/public/api.sock}"
export SPIRE_AGENT_PUBLIC_SOCKET_TEMPLATE="${SPIRE_AGENT_PUBLIC_SOCKET_TEMPLATE:-/run/spire/agent/sockets/%i/public/api.sock}"

exec /usr/libexec/spire/agent/spire-agent "$@"

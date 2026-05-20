#!/bin/bash

export SPIRE_SERVER_PRIVATE_SOCKET="${SPIRE_SERVER_PRIVATE_SOCKET:-/run/spire/server/sockets/main/private/api.sock}"
export SPIRE_SERVER_PRIVATE_SOCKET_TEMPLATE="${SPIRE_SERVER_PRIVATE_SOCKET_TEMPLATE:-/run/spire/server/sockets/%i/private/api.sock}"

exec /usr/libexec/spire/server/spire-server "$@"

#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Start up the web server
echo "Starting web server..."
docker compose -f "${DIR}"/docker-compose.yml exec -d web web-server -log /tmp/web-server.log

# Start up the echo server
echo "Starting echo server..."
docker compose -f "${DIR}"/docker-compose.yml exec -d echo echo-server -log /tmp/echo-server.log

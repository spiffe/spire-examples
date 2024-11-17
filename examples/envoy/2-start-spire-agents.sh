#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Bootstrap trust to the SPIRE server for each agent by copying over the
# trust bundle into each agent container. Alternatively, an upstream CA could
# be configured on the SPIRE server and each agent provided with the upstream
# trust bundle (see UpstreamAuthority under
# https://github.com/spiffe/spire/blob/main/doc/spire_server.md#plugin-types)
echo "Bootstrapping trust between SPIRE agents and SPIRE server..."
docker compose -f "${DIR}"/docker-compose.yml exec -T spire-server bin/spire-server bundle show |
	docker compose -f "${DIR}"/docker-compose.yml exec -T web tee conf/agent/bootstrap.crt > /dev/null
docker compose -f "${DIR}"/docker-compose.yml exec -T spire-server bin/spire-server bundle show |
	docker compose -f "${DIR}"/docker-compose.yml exec -T echo tee conf/agent/bootstrap.crt > /dev/null

# Start up the web server SPIRE agent.
echo "Starting web server SPIRE agent..."
docker compose -f "${DIR}"/docker-compose.yml exec -d web bin/spire-agent run

# Start up the echo server SPIRE agent.
echo "Starting echo server SPIRE agent..."
docker compose -f "${DIR}"/docker-compose.yml exec -d echo bin/spire-agent run

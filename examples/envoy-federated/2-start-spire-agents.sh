#!/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

bb=$(tput bold)
nn=$(tput sgr0)

# Bootstrap trust to the SPIRE server for each agent by copying over the
# trust bundle into each agent container. Alternatively, an upstream CA could
# be configured on the SPIRE server and each agent provided with the upstream
# trust bundle (see UpstreamAuthority under
# https://github.com/spiffe/spire/blob/master/doc/spire_server.md#plugin-types)
echo "${bb}Bootstrapping trust between SPIRE agents and federated SPIRE server...${nn}"
docker-compose -f "${DIR}"/docker-compose.yml exec -T spire-server-federated bin/spire-server bundle show |
	docker-compose -f "${DIR}"/docker-compose.yml exec -T web-federated tee conf/agent/bootstrap.crt > /dev/null

echo "${bb}Bootstrapping trust between SPIRE agents and SPIRE server...${nn}"
docker-compose -f "${DIR}"/docker-compose.yml exec -T spire-server-domain bin/spire-server bundle show |
	docker-compose -f "${DIR}"/docker-compose.yml exec -T echo tee conf/agent/bootstrap.crt > /dev/null

docker-compose -f "${DIR}"/docker-compose.yml exec -T spire-server-domain bin/spire-server bundle show |
	docker-compose -f "${DIR}"/docker-compose.yml exec -T web-domain tee conf/agent/bootstrap.crt > /dev/null

# Start up the web server SPIRE agent.
echo "${bb}Starting web server SPIRE agent...${nn}"
docker-compose -f "${DIR}"/docker-compose.yml exec -d web-domain bin/spire-agent run

# Start up the web-federated server SPIRE agent.
echo "${bb}Starting web-federated server SPIRE agent...${nn}"
docker-compose -f "${DIR}"/docker-compose.yml exec -d web-federated bin/spire-agent run

# Start up the echo server SPIRE agent.
echo "${bb}Starting echo server SPIRE agent...${nn}"
docker-compose -f "${DIR}"/docker-compose.yml exec -d echo bin/spire-agent run

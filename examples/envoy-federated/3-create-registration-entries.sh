#/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

bb=$(tput bold)
nn=$(tput sgr0)

fingerprint() {
	# calculate the SHA1 digest of the DER bytes of the certificate using the
	# "coreutils" output format (`-r`) to provide uniform output from
	# `openssl sha1` on macOS and linux.
	cat $1 | openssl x509 -outform DER | openssl sha1 -r | awk '{print $1}'
}

WEB_FEDERATED_AGENT_FINGERPRINT=$(fingerprint "${DIR}"/docker/web-federated/conf/agent.crt.pem)
WEB_AGENT_FINGERPRINT=$(fingerprint "${DIR}"/docker/web-domain/conf/agent.crt.pem)
ECHO_AGENT_FINGERPRINT=$(fingerprint "${DIR}"/docker/echo/conf/agent.crt.pem)

echo "${bb}Storing bundles...${nn}"
docker-compose -f "${DIR}"/docker-compose.yml exec spire-server-federated bin/spire-server bundle show |
	docker-compose -f "${DIR}"/docker-compose.yml exec -T spire-server-domain tee /opt/spire/federatedServerBundle.pem > /dev/null
docker-compose -f "${DIR}"/docker-compose.yml exec spire-server-domain bin/spire-server bundle show |
	docker-compose -f "${DIR}"/docker-compose.yml exec -T spire-server-federated tee /opt/spire/domainServerBundle.pem > /dev/null

echo "${bb}Creating federated bundle: domain...${nn}"
docker-compose -f "${DIR}"/docker-compose.yml exec spire-server-federated bin/spire-server bundle set \
	-id spiffe://domain.test \
	-path /opt/spire/domainServerBundle.pem

echo "${bb}Creating federated bundle: federated...${nn}"
docker-compose -f "${DIR}"/docker-compose.yml exec spire-server-domain bin/spire-server bundle set \
	-id spiffe://federated.test \
	-path /opt/spire/federatedServerBundle.pem

echo "${bb}Creating registration entry for the federated web server...${nn}"
docker-compose -f "${DIR}"/docker-compose.yml exec spire-server-federated bin/spire-server entry create \
	-parentID spiffe://federated.test/spire/agent/x509pop/${WEB_FEDERATED_AGENT_FINGERPRINT} \
	-spiffeID spiffe://federated.test/web-server \
	-selector unix:user:envoy \
	-federatesWith spiffe://domain.test

echo "${bb}Creating registration entry for the domain server...${nn}"
docker-compose -f "${DIR}"/docker-compose.yml exec spire-server-domain bin/spire-server entry create \
	-parentID spiffe://domain.test/spire/agent/x509pop/${ECHO_AGENT_FINGERPRINT} \
	-spiffeID spiffe://domain.test/echo-server \
	-selector unix:user:envoy \
	-federatesWith spiffe://federated.test

echo "${bb}Creating registration entry for the web server...${nn}"
docker-compose -f "${DIR}"/docker-compose.yml exec spire-server-domain bin/spire-server entry create \
	-parentID spiffe://domain.test/spire/agent/x509pop/${WEB_AGENT_FINGERPRINT} \
	-spiffeID spiffe://domain.test/web-server \
	-selector unix:user:envoy 

#/bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

fingerprint() {
	# calculate the SHA1 digest of the DER bytes of the certificate using the
	# "coreutils" output format (`-r`) to provide uniform output from
	# `openssl sha1` on macOS and linux.
	cat $1 | openssl x509 -outform DER | openssl sha1 -r | awk '{print $1}'
}

WEB_AGENT_FINGERPRINT=$(fingerprint "${DIR}"/docker/web/conf/agent.crt.pem)
ECHO_AGENT_FINGERPRINT=$(fingerprint "${DIR}"/docker/echo/conf/agent.crt.pem)

echo "Creating registration entry for the web server..."
docker compose -f "${DIR}"/docker-compose.yml exec -T spire-server bin/spire-server entry create \
	-parentID spiffe://domain.test/spire/agent/x509pop/${WEB_AGENT_FINGERPRINT} \
	-spiffeID spiffe://domain.test/web-server \
	-selector unix:user:envoy

echo "Creating registration entry for the echo server..."
docker compose -f "${DIR}"/docker-compose.yml exec -T spire-server bin/spire-server entry create \
	-parentID spiffe://domain.test/spire/agent/x509pop/${ECHO_AGENT_FINGERPRINT} \
	-spiffeID spiffe://domain.test/echo-server \
	-selector unix:user:envoy

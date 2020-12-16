
#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

bold=$(tput bold) || true
norm=$(tput sgr0) || true
red=$(tput setaf 1) || true
green=$(tput setaf 2) || true

fingerprint() {
	# calculate the SHA1 digest of the DER bytes of the certificate using the
	# "coreutils" output format (`-r`) to provide uniform output from
	# `openssl sha1` on macOS and linux.
	cat $1 | openssl x509 -outform DER | openssl sha1 -r | awk '{print $1}'
}

search_occurrences() {
  echo "$1" | grep -e "$2"
}

cleanup() {
  echo "${bold}Cleaning up...${norm}"
  docker-compose -f "${DIR}"/docker-compose.yml down
}

set_env() {
  "${DIR}"/build.sh > /dev/null
  docker-compose -f "${DIR}"/docker-compose.yml up -d
  "${DIR}"/1-start-services.sh
  "${DIR}"/2-start-spire-agents.sh
  "${DIR}"/3-create-registration-entries.sh > /dev/null
}

trap cleanup EXIT

echo "${bold}Preparing environment...${norm}"

cleanup
set_env

ECHO_CONTAINER_ID=$(docker container ls -qf "name=echo")
WEB_CONTAINER_ID=$(docker container ls -qf "name=web")

docker cp "${DIR}"/wait-for-envoy.sh "$ECHO_CONTAINER_ID":/tmp
docker cp "${DIR}"/wait-for-envoy.sh "$WEB_CONTAINER_ID":/tmp

echo "${bold}Waiting for envoy...${norm}"

docker exec -w /tmp "$ECHO_CONTAINER_ID" sh wait-for-envoy.sh Echo
docker exec -w /tmp "$WEB_CONTAINER_ID" sh wait-for-envoy.sh Web

echo "${bold}Running test...${norm}"

SECRET_PASS_HEADER="X-Super-Secret-Password"
DIRECT_RESPONSE=$(curl -s http://localhost:8080/?route=direct)

if [[ "$( echo "$(search_occurrences "$DIRECT_RESPONSE" "$SECRET_PASS_HEADER")" | wc -l)" -eq 2 ]] ; then
  echo "${green}Direct connection test succeded${norm}"
else 
  echo "${red}Direct connection test failed${norm}"
  FAILED=true
fi

EXPECTED_TIMEOUT_HEADER="X-Envoy-Expected-Rq-Timeout-Ms"
FORWARDED_PROTOCOL_HEADER="X-Forwarded-Proto"
REQUEST_ID_HEADER="X-Request-Id"
TLS_RESPONSE=$(curl -s http://localhost:8080/?route=envoy-to-envoy-tls)

if [[ $( echo "$(search_occurrences "$TLS_RESPONSE" "$SECRET_PASS_HEADER")" | wc -l) -eq 2 ]] && 
   [[ -n $(search_occurrences "$TLS_RESPONSE" "$EXPECTED_TIMEOUT_HEADER") ]] &&
   [[ -n $(search_occurrences "$TLS_RESPONSE" "$FORWARDED_PROTOCOL_HEADER") ]] &&
   [[ -n $(search_occurrences "$TLS_RESPONSE" "$REQUEST_ID_HEADER") ]]; then
    echo "${green}Envoy to Envoy TLS connection test succeded${norm}"
else
  echo "${red}Envoy to Envoy TLS connection test failed${norm}"
  FAILED=true
fi

FORWARDED_CLIENT_CERT_HEADER="X-Forwarded-Client-Cert"
CLIENT_SPIFFE_ID="spiffe://domain.test/web-server"
MTLS_RESPONSE=$(curl -s http://localhost:8080/?route=envoy-to-envoy-mtls)

if [[ "$( echo "$(search_occurrences "$MTLS_RESPONSE" "$SECRET_PASS_HEADER")" | wc -l)" -eq 2 ]] && 
   [[ -n $(search_occurrences "$MTLS_RESPONSE" "$EXPECTED_TIMEOUT_HEADER") ]] &&
   [[ -n $(search_occurrences "$MTLS_RESPONSE" "$FORWARDED_PROTOCOL_HEADER") ]] &&
   [[ -n $(search_occurrences "$MTLS_RESPONSE" "$REQUEST_ID_HEADER") ]] &&
   [[ -n $(search_occurrences "$MTLS_RESPONSE" "$FORWARDED_CLIENT_HEADER") ]] &&
   [[ -n $(search_occurrences "$MTLS_RESPONSE" "$CLIENT_SPIFFE_ID") ]]; then
    echo "${green}Envoy to Envoy mTLS connection test succeded${norm}"
else
  echo "${red}Envoy to Envoy mTLS connection test failed${norm}"
  FAILED=true
fi

echo "${bold}Updating SPIFFE ID of registration entry...${norm}"

ECHO_AGENT_FINGERPRINT=$(fingerprint "${DIR}"/docker/echo/conf/agent.crt.pem)
ECHO_ENTRY_ID=$(docker-compose -f "${DIR}"/docker-compose.yml exec spire-server bin/spire-server entry show \
  -spiffeID spiffe://domain.test/echo-server | grep "Entry ID")
ECHO_ENTRY_ID=$(echo ${ECHO_ENTRY_ID#*:} | tr -d '\r') 

docker-compose -f "${DIR}"/docker-compose.yml exec spire-server bin/spire-server entry update \
  -parentID spiffe://domain.test/spire/agent/x509pop/${ECHO_AGENT_FINGERPRINT} \
  -spiffeID spiffe://domain.test/no-echo-server \
  -selector unix:user:root \
  -entryID ${ECHO_ENTRY_ID} \
  -ttl 10 > /dev/null

ERROR_MESSAGE="unexpected echo server response status: 503"

for ((i=0;i<5;i++)); do
  TLS_RESPONSE=$(curl -s http://localhost:8080/?route=envoy-to-envoy-tls)
  if [[ -z $(search_occurrences "$TLS_RESPONSE" "$ERROR_MESSAGE") ]]; then
      echo "SVID was not rotated yet, sleeping for a while.."
      sleep 5
      continue
  else
    echo "${green}Envoy to Envoy TLS connection test after registration entries update succeded${norm}"
    SVID_ROTATED=true
    break
  fi
done

if [ -z "${SVID_ROTATED}" ]; then
  echo "${red}Envoy to Envoy TLS connection test after registration entries update failed${norm}"
  FAILED=true
fi

MTLS_RESPONSE=$(curl -s http://localhost:8080/?route=envoy-to-envoy-mtls)
if [[ -n $(search_occurrences "$MTLS_RESPONSE" "$ERROR_MESSAGE") ]]; then
    echo "${green}Envoy to Envoy mTLS connection test after registration entries update succeded${norm}"
else
  echo "${red}Envoy to Envoy mTLS connection test after registration entries update failed${norm}"
  FAILED=true
fi

if [ -n "${FAILED}" ]; then
  echo "${red}There were test failures${norm}"
  exit 1
fi
echo "${green}Test passed!${norm}"
exit 0

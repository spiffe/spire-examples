#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

bold=$(tput bold) || true
norm=$(tput sgr0) || true
red=$(tput setaf 1) || true
green=$(tput setaf 2) || true

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

run_test() {
  PORT=$1
  CLIENT_SPIFFE_ID=$2
  
  SECRET_PASS_HEADER="X-Super-Secret-Password"
  LOCAL_URL="http://localhost:${PORT}"
  DIRECT_RESPONSE=$(curl -s ${LOCAL_URL}/?route=direct)
  
  if [[ "$( echo "$(search_occurrences "$DIRECT_RESPONSE" "$SECRET_PASS_HEADER")" | wc -l)" -eq 2 ]] ; then
    echo "${green}Direct connection test succeded${norm}"
  else 
    echo "${red}Direct connection test failed${norm}"
    FAILED=true
  fi
  if [ -n "${FAILED}" ]; then
    echo "${red}There were test failures${norm}"
    exit 1
  fi
  
  EXPECTED_TIMEOUT_HEADER="X-Envoy-Expected-Rq-Timeout-Ms"
  FORWARDED_PROTOCOL_HEADER="X-Forwarded-Proto"
  REQUEST_ID_HEADER="X-Request-Id"

  for i in {1..5}; do 
    TLS_RESPONSE=$(curl -s ${LOCAL_URL}/?route=envoy-to-envoy-tls)

    if [[ $( echo "$(search_occurrences "$TLS_RESPONSE" "$SECRET_PASS_HEADER")" | wc -l) -eq 2 ]] && 
       [[ -n $(search_occurrences "$TLS_RESPONSE" "$EXPECTED_TIMEOUT_HEADER") ]] &&
       [[ -n $(search_occurrences "$TLS_RESPONSE" "$FORWARDED_PROTOCOL_HEADER") ]] &&
       [[ -n $(search_occurrences "$TLS_RESPONSE" "$REQUEST_ID_HEADER") ]]; then
        echo "${green}Envoy to Envoy TLS connection test succeded${norm}"
	FAILED=
	break
    else
      echo "${red}Envoy to Envoy TLS connection test failed, retry...${norm}"
      sleep 5
      FAILED=true
    fi
  done 
  if [ -n "${FAILED}" ]; then
    echo "${red}There were test failures${norm}"
    exit 1
  fi

  FORWARDED_CLIENT_CERT_HEADER="X-Forwarded-Client-Cert"
  for i in {1..5}; do 
     MTLS_RESPONSE=$(curl -s ${LOCAL_URL}/?route=envoy-to-envoy-mtls)
     
     if [[ "$( echo "$(search_occurrences "$MTLS_RESPONSE" "$SECRET_PASS_HEADER")" | wc -l)" -eq 2 ]] && 
        [[ -n $(search_occurrences "$MTLS_RESPONSE" "$EXPECTED_TIMEOUT_HEADER") ]] &&
        [[ -n $(search_occurrences "$MTLS_RESPONSE" "$FORWARDED_PROTOCOL_HEADER") ]] &&
        [[ -n $(search_occurrences "$MTLS_RESPONSE" "$REQUEST_ID_HEADER") ]] &&
        [[ -n $(search_occurrences "$MTLS_RESPONSE" "$FORWARDED_CLIENT_HEADER") ]] &&
        [[ -n $(search_occurrences "$MTLS_RESPONSE" "$CLIENT_SPIFFE_ID") ]]; then
         echo "${green}Envoy to Envoy mTLS connection test succeded${norm}"
         FAILED=
         break
     else
       echo "${red}Envoy to Envoy mTLS connection test failed${norm}"
       sleep 5
       FAILED=true
     fi
     done 
  if [ -n "${FAILED}" ]; then
    echo "${red}There were test failures${norm}"
    exit 1
  fi
}

trap cleanup EXIT

echo "${bold}Preparing environment...${norm}"

cleanup
set_env

ECHO_CONTAINER_ID=$(docker container ls -qf "name=echo")
WEB_DOMAIN_CONTAINER_ID=$(docker container ls -qf "name=web-domain")
echo $WEB_DOMAIN_CONTAINER_ID
WEB_FEDERATED_CONTAINER_ID=$(docker container ls -qf "name=web-federated")
echo $WEB_FEDERATED_CONTAINER_ID

docker cp "${DIR}"/wait-for-envoy.sh "$ECHO_CONTAINER_ID":/tmp
docker cp "${DIR}"/wait-for-envoy.sh "$WEB_DOMAIN_CONTAINER_ID":/tmp
docker cp "${DIR}"/wait-for-envoy.sh "$WEB_FEDERATED_CONTAINER_ID":/tmp

echo "${bold}Waiting for envoy...${norm}"

docker exec -w /tmp "$ECHO_CONTAINER_ID" sh wait-for-envoy.sh Echo
docker exec -w /tmp "$WEB_DOMAIN_CONTAINER_ID" sh wait-for-envoy.sh "Web domain"
docker exec -w /tmp "$WEB_FEDERATED_CONTAINER_ID" sh wait-for-envoy.sh "Web federated"

echo "${bold}Running domain test...${norm}"
run_test "8080" "spiffe://domain.test/web-server"
sleep 10

echo "${bold}Running federated test...${norm}"
run_test "8088" "spiffe://federated.test/web-server"

echo "${green}Test passed!${norm}"
exit 0

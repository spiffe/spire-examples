#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

bold=$(tput bold) || true
norm=$(tput sgr0) || true
red=$(tput setaf 1) || true
green=$(tput setaf 2) || true
yellow=$(tput setaf 3) || true

fail() {
	echo "${red}$*${norm}."
	exit 1
}

delete-ns() {
	echo "${bold}Cleaning up...${norm}"
    kubectl delete --ignore-not-found namespace spire > /dev/null
}

cleanup() {
    if [ -z "${GOOD}" ]; then
        echo "${yellow}Dumping statefulset/spire-server logs...${norm}"
        kubectl -nspire logs statefulset/spire-server --all-containers
        echo "${yellow}Dumping daemonset/spire-agent logs...${norm}"
        kubectl -nspire logs daemonset/spire-agent --all-containers
    fi
    delete-ns
    if [ -n "${GOOD}" ]; then
        echo "${green}Success.${norm}"
    else
        echo "${red}Failed.${norm}"
    fi
}

trap cleanup EXIT

echo "${bold}Preparing environment...${norm}"
delete-ns
kubectl create namespace spire

echo "${bold}Applying configuration...${norm}"
kubectl apply -k "${DIR}"

LOGLINE="Node attestation request completed"
for ((i=0;i<120;i++)); do
    if ! kubectl -nspire rollout status statefulset/spire-server; then
        sleep 1
        continue
    fi
    if ! kubectl -nspire rollout status daemonset/spire-agent; then
        sleep 1
        continue
    fi
    if ! kubectl -nspire logs statefulset/spire-server -c spire-server | grep -e "$LOGLINE" ; then
        sleep 1
        continue
    fi
    echo "${bold}Node attested.${norm}"
    GOOD=1
    exit 0
done

echo "${red}Timed out waiting for node to attest.${norm}"
exit 1

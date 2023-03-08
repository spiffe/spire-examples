#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bold=$(tput bold) || true
norm=$(tput sgr0) || true
red=$(tput setaf 1) || true
green=$(tput setaf 2) || true

fail() {
  echo "${red}$*${norm}."
  exit 1
}

echo "${bold}Checking for kubectl...${norm}"
command -v kubectl >/dev/null || fail "kubectl is required."

echo "${bold}Checking kind status...${norm}"
if ! kind get clusters | grep demo-cluster; then
  kind create cluster -n demo-cluster || fail "Failed to create cluster"
fi

echo "${bold}Running all tests...${norm}"
for testdir in "${DIR}"/*; do
  if [[ -x "${testdir}/test.sh" ]]; then
    testname=$(basename "$testdir")
    echo "${bold}Running \"$testname\" test...${norm}"
    if KEEP_CLUSTER=1 ${testdir}/test.sh; then
      echo "${green}\"$testname\" test succeeded${norm}"
    else
      echo "${red}\"$testname\" test failed${norm}"
      FAILED=true
    fi
  fi
done

echo "${bold}Deleting cluster...${norm}"
kind delete cluster -n demo-cluster >/dev/null

if [ -n "${FAILED}" ]; then
  fail "There were test failures"
fi
echo "${bold}Done.${norm}"

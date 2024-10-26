#!/bin/bash

ARCH="$(uname -m | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)"

# Install deps from prebuilt binaries and scripts
cd /tmp
curl -L -o helper.tgz https://github.com/spiffe/spiffe-helper/releases/download/v0.8.0/spiffe-helper-v0.8.0.tar.gz
tar -xvf helper.tgz
mv spiffe-helper /bin
curl -L -o spire.tgz "https://github.com/spiffe/spire/releases/download/v1.11.0/spire-1.11.0-linux-${ARCH}-musl.tar.gz"
tar -xvf spire.tgz
mv spire-*/bin/spire-agent /bin
curl -L -o step.tgz "https://dl.smallstep.com/gh-release/cli/gh-release-header/v0.27.4/step_linux_0.27.4_${ARCH}.tar.gz"
tar -xvf step.tgz
mv step*/bin/step /bin
curl -L -o /etc/systemd/system/spire-agent.target https://raw.githubusercontent.com/spiffe/spire-examples/refs/heads/main/examples/systemd/system/spire-agent.target
curl -L -o /etc/systemd/system/spire-agent@.service https://raw.githubusercontent.com/spiffe/spire-examples/refs/heads/main/examples/systemd/system/spire-agent@.service
curl -L -o /etc/systemd/system/spire.target https://raw.githubusercontent.com/spiffe/spire-examples/refs/heads/main/examples/systemd/system/spire.target

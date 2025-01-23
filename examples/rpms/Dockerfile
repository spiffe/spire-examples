ARG STEPVER="0.28.2"

FROM docker.io/library/almalinux:9 AS rpm-builder
ARG STEPVER

WORKDIR /tmp

COPY *.spec /tmp

RUN \
  dnf install -y rpmdevtools rpm-build git make && \
  spectool -g -R spire.spec && \
  rpmbuild -ba spire.spec && \
  spectool -g -R spiffe-step-ssh.spec && \
  rpmbuild -ba spiffe-step-ssh.spec && \
  spectool -g -R spire-ha-agent.spec && \
  rpmbuild -ba spire-ha-agent.spec

RUN \
  dnf localinstall -y https://github.com/smallstep/cli/releases/download/v${STEPVER}/step-cli-${STEPVER}-1.$(uname -i).rpm && \
  dnf localinstall -y /root/rpmbuild/RPMS/*/*.rpm

FROM docker.io/library/ubuntu:latest AS deb-builder
ARG STEPVER

COPY --from=rpm-builder /root/rpmbuild/RPMS /root/rpmbuild/RPMS

RUN \
  apt-get update && \
  apt-get install -y software-properties-common && \
  add-apt-repository universe && \
  apt-get install -y alien && \
  mkdir -p /root/debbuild && \
  cd /root/debbuild && \
  mkdir $(dpkg --print-architecture) && \
  cd * && \
  alien -k -c --to-deb /root/rpmbuild/RPMS/*/*.rpm

RUN \
  curl -L -o step-cli.deb https://github.com/smallstep/cli/releases/download/v${STEPVER}/step-cli_${STEPVER}-1_$(dpkg --print-architecture).deb && \
  apt-get install -y ./step-cli.deb && \
  apt-get install -y /root/debbuild/*/*.deb

FROM docker.io/library/nginx:latest
COPY --from=rpm-builder /root/rpmbuild/RPMS /usr/share/nginx/html/packages/RPMS
COPY --from=deb-builder /root/debbuild /usr/share/nginx/html/packages/DEBS

ARG STEPVER="0.28.2"

FROM docker.io/library/almalinux:9 AS rpm-builder
ARG STEPVER

WORKDIR /tmp

COPY rpms/*.spec /tmp
ADD rpms/rpm.pub /tmp/rpm.pub
ADD rpms/rpmmacros /root/.rpmmacros

COPY systemd /tmp/systemd

RUN --mount=type=secret,id=gpg \
  mkdir -p /root/rpmbuild/SOURCES && \
  tar -zcvf /root/rpmbuild/SOURCES/spire-extras-systemd.tar.gz systemd && \
  dnf install -y which rpmdevtools rpm-build rpm-sign git make && \
  spectool -g -R spire.spec && \
  rpmbuild -ba spire.spec && \
  spectool -g -R spiffe-helper.spec && \
  rpmbuild -ba spiffe-helper.spec && \
  spectool -g -R spiffe-step-ssh.spec && \
  rpmbuild -ba spiffe-step-ssh.spec && \
  spectool -g -R spire-ha-agent.spec && \
  rpmbuild -ba spire-ha-agent.spec && \
  spectool -g -R k8s-spiffe-workload-jwt-exec-auth.spec && \
  rpmbuild -ba k8s-spiffe-workload-jwt-exec-auth.spec && \
  spectool -g -R k8s-spiffe-workload-auth-config.spec && \
  rpmbuild -ba k8s-spiffe-workload-auth-config.spec && \
  spectool -g -R spire-server-nodeattestor-tpmdirect.spec && \
  rpmbuild -ba spire-server-nodeattestor-tpmdirect.spec && \
  spectool -g -R spire-agent-nodeattestor-tpmdirect.spec && \
  rpmbuild -ba spire-agent-nodeattestor-tpmdirect.spec && \
  if [ -f /run/secrets/gpg ]; then \
    gpg --import /run/secrets/gpg && \
    gpg --import rpm.pub && \
    rpm --addsign /root/rpmbuild/RPMS/*/*.rpm; \
  else \
    true; \
  fi

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

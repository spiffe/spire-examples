FROM docker.io/library/almalinux:9 AS rpm-builder

WORKDIR /tmp

COPY spire.spec /tmp
RUN \
  dnf install -y rpmdevtools rpm-build git make && \
  spectool -g -R  spire.spec && \
  rpmbuild -ba spire.spec

RUN \
  dnf localinstall -y /root/rpmbuild/RPMS/*/*.rpm

FROM docker.io/library/ubuntu:latest AS deb-builder

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
  apt-get install -y /root/debbuild/*/*.deb

FROM docker.io/library/nginx:latest
COPY --from=rpm-builder /root/rpmbuild/RPMS /usr/share/nginx/html/packages/RPMS
COPY --from=deb-builder /root/debbuild /usr/share/nginx/html/packages/DEBS

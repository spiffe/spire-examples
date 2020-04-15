# TODO: replace hash for 0.10.0
FROM gcr.io/spiffe-io/spire-server:429286051c1e0d729be2bec8d7ee26204494cf7a

# Override spire configurations
COPY conf/spire-server.conf /opt/spire/conf/server/server.conf
COPY conf/agent-cacert.pem /opt/spire/conf/server/agent-cacert.pem

WORKDIR /opt/spire

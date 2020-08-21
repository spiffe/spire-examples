FROM gcr.io/spiffe-io/spire-server@sha256:fe149f1d01d3536bd48fa10f49903be039e6f966afdafc946b247828c169cc69 

# Override spire configurations
COPY conf/spire-server.conf /opt/spire/conf/server/server.conf
COPY conf/agent-cacert.pem /opt/spire/conf/server/agent-cacert.pem

WORKDIR /opt/spire

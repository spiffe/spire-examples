FROM gcr.io/spiffe-io/spire-server:0.12.0
# FROM gcr.io/spiffe-io/spire-server:0.11.0
# FROM gcr.io/spiffe-io/spire-server@sha256:818c3e3ae7e1e576c08c7f685bcc3d538c7130c272516b4e4653b7115460e64b

# Override spire configurations
COPY conf/spire-server.conf /opt/spire/conf/server/server.conf
COPY conf/agent-cacert.pem /opt/spire/conf/server/agent-cacert.pem

WORKDIR /opt/spire

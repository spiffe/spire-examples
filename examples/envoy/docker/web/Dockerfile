# FROM gcr.io/spiffe-io/spire-agent:0.11.0 as spire
FROM gcr.io/spiffe-io/spire-agent:0.12.0 as spire
# FROM gcr.io/spiffe-io/spire-agent@sha256:e93e6879cc2a231a4983444312d8c32523c1106f388df275dca0db484cca312f as spire

FROM envoyproxy/envoy-alpine:v1.17.0
RUN mkdir -p /opt/spire/conf/agent
RUN mkdir -p /opt/spire/data/agent
COPY --from=spire /opt/spire/bin/spire-agent /opt/spire/bin/spire-agent
COPY conf/envoy.yaml /etc/envoy/envoy.yaml
COPY conf/spire-agent.conf /opt/spire/conf/agent/agent.conf
COPY conf/agent.key.pem /opt/spire/conf/agent/agent.key.pem
COPY conf/agent.crt.pem /opt/spire/conf/agent/agent.crt.pem
COPY web-server /usr/local/bin/web-server

WORKDIR /opt/spire
CMD /usr/local/bin/envoy -l debug -c /etc/envoy/envoy.yaml --log-path /tmp/envoy.log


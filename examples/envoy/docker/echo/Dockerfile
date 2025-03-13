FROM ghcr.io/spiffe/spire-agent:1.11.2 as spire

FROM envoyproxy/envoy:v1.25.1
RUN mkdir -p /opt/spire/conf/agent
RUN mkdir -p /opt/spire/data/agent
COPY --from=spire /opt/spire/bin/spire-agent /opt/spire/bin/spire-agent
COPY conf/envoy.yaml /etc/envoy/envoy.yaml
COPY conf/spire-agent.conf /opt/spire/conf/agent/agent.conf
COPY conf/agent.key.pem /opt/spire/conf/agent/agent.key.pem
COPY conf/agent.crt.pem /opt/spire/conf/agent/agent.crt.pem
COPY echo-server /usr/local/bin/echo-server

WORKDIR /opt/spire
CMD /usr/local/bin/envoy -l debug -c /etc/envoy/envoy.yaml --log-path /tmp/envoy.log

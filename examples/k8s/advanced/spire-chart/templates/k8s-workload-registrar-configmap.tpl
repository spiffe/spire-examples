apiVersion: v1
kind: ConfigMap
metadata:
  name: k8s-workload-registrar
  namespace: {{ .Values.namespace }}
data:
  registrar.conf: |
    log_level = "debug"
    mode = "reconcile"
    trust_domain = "{{ .Values.trustdomain }}"
    server_socket_path = "/run/spire/sockets/registration.sock"
    cluster = "{{ .Values.clustername }}"

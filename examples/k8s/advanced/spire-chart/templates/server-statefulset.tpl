apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: spire-server
  namespace: {{ .Values.namespace }}
  labels:
    app: spire-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: spire-server
  serviceName: spire-server
  template:
    metadata:
      namespace: spire
      labels:
        app: spire-server
    spec:
      serviceAccountName: spire-server
      shareProcessNamespace: true
      containers:
        - name: spire-server
          image: gcr.io/spiffe-io/spire-server:0.11.0
          args:
            - -config
            - /run/spire/config/server.conf
          ports:
            - containerPort: 8081
          volumeMounts:
            - name: spire-server-socket
              mountPath: /run/spire/sockets
              readOnly: false
            - name: spire-config
              mountPath: /run/spire/config
              readOnly: true
            - name: spire-data
              mountPath: /run/spire/data
              readOnly: false
            - name: spire-secret
              mountPath: /run/spire/secret
          livenessProbe:
            exec:
              command:
                - /opt/spire/bin/spire-server
                - healthcheck
            failureThreshold: 2
            initialDelaySeconds: 15
            periodSeconds: 6000
            timeoutSeconds: 3
        - name: k8s-workload-registrar
          #image: k8s-workload-registrar:latest
          image: gcr.io/spiffe-io/k8s-workload-registrar@sha256:912484f6c0fb40eafb16ba4dd2d0e1b0c9d057c2625b8ece509f5510eaf5b704
          imagePullPolicy: Always
          args:
            - -config
            - /run/k8s-workload-registrar/config/registrar.conf
          volumeMounts:
            - name: spire-server-socket
              mountPath: /run/spire/sockets
              readOnly: false
            - name: k8s-workload-registrar-config
              mountPath: /run/k8s-workload-registrar/config
              readOnly: true
      volumes:
        - name: spire-server-socket
          hostPath:
            path: /run/spire/server-sockets
            type: DirectoryOrCreate
        - name: spire-config
          configMap:
            name: spire-server
        - name: k8s-workload-registrar-config
          configMap:
            name: k8s-workload-registrar
        - name: spire-secret
          secret:
            secretName: spire-secret
        - name: spire-entries
          configMap:
            name: spire-entries
        - name: spire-data
          hostPath:
            path: /var/spire-data
            type: DirectoryOrCreate

# Simple SPIRE 0.11.0 deployment using PSAT node attestor

This configuration is an example of a simple SPIRE 0.11.0 deployment for Kubernetes that uses [PSAT node attestor](https://github.com/spiffe/spire/blob/v0.11.0/doc/plugin_server_nodeattestor_k8s_psat.md).

+ The SPIRE [server](spire-server.yaml) runs as a StatefulSet using a
  PersistentVolumeClaim.
+ The SPIRE [agent](spire-agent.yaml) runs as a DaemonSet.

Both SPIRE agent and server run in the **spire** namespace, using service
accounts of **spire-server** and **spire-agent**.
Also RBAC authorization policies are set in order to guarantee access to certain API server resources.

## Usage

### Configuration

The following flags must be passed to the Kubernetes API server to properly run this PSAT attestor example:
+ `service-account-signing-key-file`
+ `service-account-key-file`
+ `service-account-issuer`
+ `service-account-api-audiences`

If you are using minikube, make sure it is started as follows:
```
minikube start  --vm-driver=virtualbox \
                --extra-config=apiserver.authorization-mode=Node,RBAC \
                --extra-config=apiserver.service-account-signing-key-file=/var/lib/minikube/certs/sa.key \
                --extra-config=apiserver.service-account-key-file=/var/lib/minikube/certs/sa.pub \
                --extra-config=apiserver.service-account-issuer=api \
                --extra-config=apiserver.service-account-api-audiences=api,spire-server
```

### Deployment

Start the server StatefulSet:

```
$ kubectl apply -f spire-server.yaml
```

Start the agent DaemonSet:

```
$ kubectl apply -f spire-agent.yaml
```

The agent should automatically attest to SPIRE server.

# Simple SPIRE 1.5.1 deployment using PSAT node attestor

This configuration is an example of a simple SPIRE 1.5.1 deployment for Kubernetes that uses [PSAT node attestor](https://github.com/spiffe/spire/blob/v1.5.1/doc/plugin_server_nodeattestor_k8s_psat.md).

+ The SPIRE [server](spire-server.yaml) runs as a StatefulSet using a
  PersistentVolumeClaim.
+ The SPIRE [agent](spire-agent.yaml) runs as a DaemonSet.

Both SPIRE agent and server run in the **spire** namespace, using service
accounts of **spire-server** and **spire-agent**.
Also, RBAC authorization policies are set in order to guarantee access to certain API server resources.

## Usage


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

## Test

Simply run `./test.sh`, this script will start a cluster using [kind](https://kind.sigs.k8s.io/), deploy spire server and
agent, and run a simple test to verify the node attestation process using PSAT NodeAttestor.

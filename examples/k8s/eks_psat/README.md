# SPIRE deployment using PSAT node attestor on EKS

This configuration is an example of a SPIRE deployment for Kubernetes on EKS. This example is based on the [simple PSAT](../simple_psat/README.md), with minor modifications to make it work on EKS platform.

Compare the [simple PSAT server](../simple_psat/spire-server.yaml) configuration with
this [EKS PSAT server](spire-server.yaml) to see the differences, which
consist of:

+ Node attestation is done using the [PSAT node attestor](https://github.com/spiffe/spire/blob/main/doc/plugin_server_nodeattestor_k8s_psat.md)
with kubernetes token review validation enabled.
+ As a consequence of the above, volume and volume mounts for validation key are removed.
+ RBAC authorization policies are set to guarantee access to certain Kubernetes resources.

In the same way, the differences between the [simple PSAT agent](../simple_psat/spire-agent.yaml) and [EKS PSAT server](spire-agent.yaml) are:
+ Workload attestation is done using the [k8s workload attestor](https://github.com/spiffe/spire/blob/main/doc/plugin_agent_workloadattestor_k8s.md) with the secure port configuration.
+ RBAC authorization policies are set to guarantee access to certain Kubernetes resources.

Both SPIRE agent and server run in the **spire** namespace, using service accounts of **spire-server** and **spire-agent**.

## Usage

### Pre-requisites
+ Create an EKS cluster and set it as the current context for `kubectl`. No special configurations are required for the [cluster creation](https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html).

### Deployment

Start the server StatefulSet:

```
$ kubectl apply -f spire-server.yaml
```

Start the agent DaemonSet:

```
$ kubectl apply -f spire-agent.yaml
```

The server log shows the attestation result:

```
$ kubectl -n spire logs -f spire-server-0
```
```
level=info msg="Node attestation request from 192.168.21.111:56628 completed using strategy k8s_psat" subsystem_name=node_api
```

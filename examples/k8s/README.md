# Example Kubernetes Configurations

This directory contains some example Kubernetes configurations. They are nightly tested agaist fixed SPIRE versions.

+ [simple sat on SPIRE 0.7.3](simple_sat) - This is a simple configuration using the Kubernetes
  [service account token (SAT) attestor](https://github.com/spiffe/spire/blob/0.7.3/doc/plugin_server_nodeattestor_k8s_sat.md)
  that deploys SPIRE server as a StatefulSet and SPIRE agent as a DaemonSet.
+ [simple psat on SPIRE 0.8.0](simple_psat) - This is a simple configuration using the
  Kubernetes
  [projected service account token (PSAT) attestor](https://github.com/spiffe/spire/blob/0.8.0/doc/plugin_server_nodeattestor_k8s_psat.md)
  that otherwise deploys SPIRE as in the **simple sat** example.
+ [postgres on SPIRE 0.7.3](postgres) - This expands on the **simple sat** configuration by
  moving the SPIRE datastore into a Postgres StatefulSet. The SPIRE server is
  now a stateless Deployment that can be scaled.
+ [eks sat on SPIRE 0.8.0](eks_sat) - This slightly modifies the **simple sat** configuration to
  make it compatible with EKS platform.
+ [k7e](k7e) - A set of SPIRE examples using [Kustomize](https://kustomize.io/)
  as shown at the SPIFFE Community Day in May, 2019.

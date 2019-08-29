# SPIRE Examples

Hello, and welcome to SPIRE examples!

This repository houses various SPIFFE/SPIRE deployment and integration examples. All examples are self contained, and come with instructions on how to use them.

The SPIRE project is growing rapidly, and new features are released often. In order to ensure the accuracy of accompanying documentation, each example is written against a specific version of SPIRE. All examples are regularly tested against the stated SPIRE version, but are likely to work with newer versions as well.

## Envoy

Examples showing how SPIRE integrates with Envoy.

* [Envoy SDS Integration with SPIRE 0.8.0](examples/envoy) Use SPIRE to deliver and rotate X509-SVIDs for Envoy

## Kubernetes

Examples showing how to deploy SPIRE on Kubernetes. There are several configuration possibilities.

+ [Simple SAT with SPIRE 0.7.3](examples/k8s/simple_sat) - This is a simple configuration using the Kubernetes
  [service account token (SAT) attestor](https://github.com/spiffe/spire/blob/0.7.3/doc/plugin_server_nodeattestor_k8s_sat.md)
  that deploys SPIRE server as a StatefulSet and SPIRE agent as a DaemonSet.
+ [Simple PSAT with SPIRE 0.8.0](examples/k8s/simple_psat) - This is a simple configuration using the
  Kubernetes
  [projected service account token (PSAT) attestor](https://github.com/spiffe/spire/blob/0.8.0/doc/plugin_server_nodeattestor_k8s_psat.md)
  that otherwise deploys SPIRE as in the **Simple SAT** example.
+ [Postgres with SPIRE 0.7.3](examples/k8s/postgres) - This expands on the **Simple SAT** configuration by
  moving the SPIRE datastore into a Postgres StatefulSet. The SPIRE server is
  now a stateless Deployment that can be scaled.
+ [Kustomize with SPIRE 0.8.0](examples/k8s/k7e) - A set of SPIRE examples using [Kustomize](https://kustomize.io/)
  as shown at the SPIFFE Community Day in May, 2019.

## EKS

+ [EKS-based SAT with SPIRE 0.8.0](examples/k8s/eks_sat) - This slightly modifies the **Kubernetes Simple SAT** configuration to
  make it compatible with EKS platform.

## Getting Help

If you have any questions on the above examples, or anything else related to deploying or maintaining SPIRE, please feel free to either [open an issue](https://github.com/spiffe/spire-examples/issues/new) or ask in #help on our [Slack](https://slack.spiffe.io/).

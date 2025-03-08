[![Build Status](https://github.com/spiffe/spire-examples/actions/workflows/pr_build.yaml/badge.svg)](https://github.com/spiffe/spire-examples/actions/workflows/pr_build.yaml)

# SPIRE Examples

Hello, and welcome to SPIRE examples!

This repository houses various SPIFFE/SPIRE deployment and integration examples. All examples are self contained, and come with instructions on how to use them.

The SPIRE project is growing rapidly, and new features are released often. In order to ensure the accuracy of accompanying documentation, each example is written against a specific version of SPIRE. All examples are regularly tested against the stated SPIRE version, but are likely to work with newer versions as well.

## Envoy

Examples showing how SPIRE integrates with Envoy.

* [Envoy SDS Integration](examples/envoy) Use SPIRE to deliver and rotate X509-SVIDs for Envoy

## Kubernetes

Examples showing how to deploy SPIRE on Kubernetes. There are several configuration possibilities.

+ [Simple PSAT](examples/k8s/simple_psat) - This is a simple configuration using the
  Kubernetes
  [projected service account token (PSAT) attestor](https://github.com/spiffe/spire/blob/main/doc/plugin_server_nodeattestor_k8s_psat.md).
+ [Postgres](examples/k8s/postgres) - This expands on the **Simple PSAT** configuration by
  moving the SPIRE datastore into a Postgres StatefulSet. The SPIRE server is
  now a stateless Deployment that can be scaled.
+ [Kustomize](examples/k8s/k7e) - A set of SPIRE examples using [Kustomize](https://kustomize.io/)
  as shown at the SPIFFE Community Day in May 2019.

## EKS

Examples showing how to deploy SPIRE on Amazon EKS.

+ [EKS-based SAT](examples/k8s/eks_psat) - This slightly modifies the **Kubernetes Simple PSAT** configuration to
  make it compatible with EKS platform.

## SystemD

Examples showing how to start up SPIRE services using SystemD

* [SystemD](examples/systemd) SPIRE services managed by SystemD

## Getting Help

If you have any questions on the above examples, or anything else related to deploying or maintaining SPIRE, please feel free to either [open an issue](https://github.com/spiffe/spire-examples/issues/new) or ask in #help on our [Slack](https://slack.spiffe.io/).

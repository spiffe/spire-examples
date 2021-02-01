#!/bin/sh
set -o errexit

# create registry container unless it already exists
reg_name='kind-registry'
reg_port='5000'
running="$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)"
if [ "${running}" != 'true' ]; then
  docker run \
    -d --restart=always -p "${reg_port}:5000" --name "${reg_name}" \
    registry:2
fi

# Create the cluster.
# The containerdConfigPatches line is useful to configure access to the local registry.
# The ClusterConfiguration options are needed for nodes to access projected service
# account tokens.
# The example uses serviceAccountToken that is by default enabled in K8s 1.20
# To simplify the deployment, select a node image with K8s 1.20 or higher.
# The complete list of Kind images: https://github.com/kubernetes-sigs/kind/releases
cat <<EOF | kind create cluster --name spire-example -v 5 --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${reg_port}"]
    endpoint = ["http://${reg_name}:${reg_port}"]
nodes:
- role: control-plane
  image: kindest/node:v1.20.2@sha256:8f7ea6e7642c0da54f04a7ee10431549c0257315b3a634f6ef2fecaaedb19bab
  kubeadmConfigPatches:
  - |
EOF

#    kind: ClusterConfiguration
#    apiServer:
#      extraArgs:
#       service-account-issuer: api
#service-account-signing-key-file: /etc/kubernetes/pki/apiserver.key
#       service-account-api-audiences: api
# connect the registry to the cluster network
# docker network connect "kind" "${reg_name}"
# TODO check why this does not work -- it is not needed for now

# tell https://tilt.dev to use the registry
# https://docs.tilt.dev/choosing_clusters.html#discovering-the-registry
for node in $(kind get nodes); do
  kubectl annotate node "${node}" "kind.x-k8s.io/registry=localhost:${reg_port}";
done

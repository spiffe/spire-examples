#!/bin/bash 

pushd spire-k8s-image
bash build.sh
kind load docker-image spire-k8s-image
popd

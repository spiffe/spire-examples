#!/bin/sh
which kind || (echo "kind not found"; exit 1)
which helm || (echo "helm not found"; exit 1)
which docker || (echo "docker not found"; exit 1)
(helm version | grep "Version:\"v3.") || (echo "Helm is not version 3"; exit 1)

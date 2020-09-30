#!/bin/bash
kubectl logs spire-server-0 -c k8s-workload-registrar -n spire 

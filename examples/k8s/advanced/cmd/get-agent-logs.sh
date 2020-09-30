#!/bin/bash
agent_pods=`kubectl get pods -l app=spire-agent -n spire -o name`
for agent in $agent_pods
do
  kubectl logs $agent -n spire
done

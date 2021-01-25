#!/bin/sh
kind delete cluster --name spire-example
docker kill registry
docker rm registry

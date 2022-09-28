#!/usr/bin/env bash

set -e

# Make sure that extensions can resolve host aliases

declare -a host_aliases=("dxp" "vi")
HOST_ALIASES="['dxp', 'vi']"

ytt -f /repo/k8s/k3d --data-value-yaml "hostAliases=$HOST_ALIASES" > .cluster_config.yaml

# start k3d cluster
CLUSTER=$(k3d cluster list -o json | jq -r '.[] | select(.name=="localdev")')

if [ "$CLUSTER" == "" ];then
  echo "localdev cluster does not exist"
  exit 1
fi

# is cluster running?
CLUSTER_STATUS=$(jq -r '.serversRunning > 0' <<< $CLUSTER)

if [ "$CLUSTER_STATUS" == "true" ];then
  echo "localdev cluster is already started"
  exit 1
fi

k3d cluster start localdev

kubectl config use-context k3d-localdev
kubectl config set-context --current --namespace=default

echo "localdev cluster is ready."
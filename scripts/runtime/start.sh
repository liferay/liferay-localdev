#!/usr/bin/env bash

set -e

# start k3d cluster
/repo/scripts/runtime/create.sh

/repo/scripts/dnsmasq-start.sh

CLUSTER=$(k3d cluster list -o json | jq -r '.[] | select(.name=="localdev")')

# is cluster running?
CLUSTER_STATUS=$(jq -r '.serversRunning > 0' <<< $CLUSTER)

if [ "$CLUSTER_STATUS" == "true" ];then
  echo "'localdev' runtime environment is started."
  exit 0
fi

k3d cluster start localdev

echo "'localdev' runtime environment is started."
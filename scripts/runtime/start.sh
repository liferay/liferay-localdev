#!/usr/bin/env bash

set -e

REPO="${LOCALDEV_REPO:-/repo}"

# start k3d cluster
${REPO}/scripts/runtime/create.sh

${REPO}/scripts/dnsmasq-start.sh

CLUSTER=$(k3d cluster list -o json | jq -r '.[] | select(.name=="localdev")')

# is cluster running?
CLUSTER_STATUS=$(jq -r '.serversRunning > 0' <<< $CLUSTER)

if [ "$CLUSTER_STATUS" == "true" ];then
  echo "[002] 'localdev' runtime environment is started."
  exit 0
fi

k3d cluster start localdev

echo "[003] 'localdev' runtime environment is started."
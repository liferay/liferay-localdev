#!/usr/bin/env bash

set -e

REPO="${LOCALDEV_REPO:-/repo}"

# start k3d cluster
${REPO}/scripts/runtime/create.sh

${REPO}/scripts/dnsmasq-start.sh

CLUSTER=$(k3d cluster list -o json | jq -r '.[] | select(.name=="localdev")')

# is cluster running?
CLUSTER_STATUS=$(jq -r '.serversRunning > 0' <<< $CLUSTER)

if [ "$CLUSTER_STATUS" != "true" ];then
	echo "'localdev' runtime environment is not started."
	exit 1
fi

echo "'localdev' runtime environment is started."
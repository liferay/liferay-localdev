#!/usr/bin/env bash

set -e

# Make sure that extensions can resolve host aliases

# create k3d cluster with local registry
CLUSTER=$(k3d cluster list -o json | jq -r '.[] | select(.name=="localdev")')

if [ "$CLUSTER" == "" ];then
  echo "'localdev' runtime environment does not exist."
  exit 0
else
  CLUSTER_STATUS=$(jq -r '.serversRunning > 0' <<< $CLUSTER)

  if [ "$CLUSTER_STATUS" == "true" ];then
    echo "'localdev' runtime environment is started."
    exit 0
  fi

  echo "'localdev' runtime environment is not started."
fi

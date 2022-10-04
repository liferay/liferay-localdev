#!/usr/bin/env bash

set -e

CLUSTER=$(k3d cluster list -o json | jq -r '.[] | select(.name=="localdev")')

if [ "$CLUSTER" == "" ];then
  echo "'localdev' runtime environment does not exist."
  exit 1
fi

if /repo/scripts/ext/status.sh; then
  exit 0
fi

export DO_NOT_TRACK=1

tilt up -f /repo/tilt/Tiltfile

echo "'localdev' extension environment started."
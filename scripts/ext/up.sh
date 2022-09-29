#!/usr/bin/env bash

set -e

CLUSTER=$(k3d cluster list -o json | jq -r '.[] | select(.name=="localdev")')

if [ "$CLUSTER" == "" ];then
  echo "'localdev' runtime environment does not exist"
  echo "To create a 'localdev' runtime, execute `lcectl runtime create`"
  exit 1
fi

export DO_NOT_TRACK=1

tilt up -f /repo/tilt/Tiltfile
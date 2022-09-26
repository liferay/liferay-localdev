#!/usr/bin/env bash

set -ex

if [ -z "$LOCALDEV_REPO" ]; then
  echo "Must specify LOCALDEV_REPO env var"
  exit 1
fi

docker \
  run \
  --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $LOCALDEV_REPO:/repo \
  -v $(pwd):/workspace/client-extensions \
  localdev \
  tilt down -f /repo/tilt/Tiltfile

docker kill localdev-server
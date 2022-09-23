#!/usr/bin/env bash

set -ex

if [ -z "$LOCALDEV_REPO" ]; then
  echo "Must specify LOCALDEV_REPO env var"
  exit 1
fi

if [ -z "$LIFERAY_CACHE" ]; then
  echo "Must specify LIFERAY_CACHE env var"
  exit 1
fi

docker \
  run \
  --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $LOCALDEV_REPO:/repo \
  -v $LIFERAY_CACHE:/root/.liferay/ \
  -v $(pwd):/workspace/client-extensions \
  lxc-localdev \
  tilt down -f /repo/tilt/Tiltfile
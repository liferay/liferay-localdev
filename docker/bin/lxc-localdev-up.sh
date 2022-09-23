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
  --name lxc-localdev-runner \
  --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $LOCALDEV_REPO:/repo \
  -v $LIFERAY_CACHE:/root/.liferay/ \
  -v $(pwd):/workspace/client-extensions \
  --expose 10350 \
  -p 10350:10350 \
  -e DO_NOT_TRACK="1" \
  lxc-localdev \
  tilt up -f /repo/tilt/Tiltfile --stream
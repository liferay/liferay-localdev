#!/usr/bin/env bash

set -ex

if [ -z "$LOCALDEV_REPO" ]; then
  echo "Must specify LOCALDEV_REPO env var"
  exit 1
fi

docker \
  run \
  --name localdev-server-down \
  --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v localdevGradleCache:/root/.gradle \
  -v localdevLiferayCache:/root/.liferay \
  -v $LOCALDEV_REPO:/repo \
  -v $(pwd):/workspace/client-extensions \
  localdev-server \
  tilt down -f /repo/tilt/Tiltfile

docker kill localdev-server
#!/usr/bin/env bash

set -ex

if [ -z "$LOCALDEV_REPO" ]; then
  echo "Must specify LOCALDEV_REPO env var"
  exit 1
fi

if [ -z "$DOCKER_NETWORK" ]; then
  echo "Must specify DOCKER_NETWORK env var"
  exit 1
fi

# host on linux or bridge on mac
docker run \
  --name localdev-cmd \
  --network ${DOCKER_NETWORK} \
  --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $LOCALDEV_REPO:/repo \
  localdev \
  $@
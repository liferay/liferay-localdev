#!/usr/bin/env bash

set -ex

if [ -z "$DOCKER_NETWORK" ]; then
  echo "Must specify DOCKER_NETWORK env var"
  exit 1
fi

docker run \
  --name localdev-server-refresh \
  --network ${DOCKER_NETWORK} \
  --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  localdev-server \
  tilt trigger "(Tiltfile)" --host host.docker.internal
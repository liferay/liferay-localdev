#!/usr/bin/env bash

set -ex

if [ -z "$LOCALDEV_REPO" ]; then
  echo "Must specify LOCALDEV_REPO env var"
  exit 1
fi

(sleep 5 && open http://localhost:10350) &

docker \
  run \
  --name lxc-localdev-server \
  --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $LOCALDEV_REPO:/repo \
  -v $(pwd):/workspace/client-extensions \
  --expose 10350 \
  -p 10350:10350 \
  -e DO_NOT_TRACK="1" \
  lxc-localdev \
  tilt up -f /repo/tilt/Tiltfile --stream
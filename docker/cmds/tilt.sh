#!/usr/bin/env bash

LOCALDEV_REPO=$1
LIFERAY_CACHE=$2
CLIENT_EXTENSIONS_SOURCE=$3
CLIENT_EXTENSIONS_DEPLOY=$3

docker \
  run \
  --name lxc-localdev-runner \
  --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $LOCALDEV_REPO:/repo \
  -v $LIFERAY_CACHE:/root/.liferay/ \
  -v $CLIENT_EXTENSIONS_SOURCE:/workspace/client-extensions \
  -v $CLIENT_EXTENSIONS_DEPLOY:/workspace/build/docker/client-extensions \
  --expose 10350 \
  -p 10350:10350 \
  -e DO_NOT_TRACK="1" \
  lxc-localdev \
  tilt \
  $@
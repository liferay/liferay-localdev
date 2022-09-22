#!/usr/bin/env bash

LOCALDEV_REPO=$1
LIFERAY_CACHE=$2
CLIENT_EXTENSIONS=$3

docker \
  run \
  --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $LOCALDEV_REPO:/repo \
  -v $LIFERAY_CACHE:/root/.liferay/ \
  -v $CLIENT_EXTENSIONS:/workspace/client-extensions \
  lxc-localdev \
  $@
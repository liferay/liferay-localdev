#!/usr/bin/env bash

set -ex

IMAGE=dxp-server

REPO="${LOCALDEV_REPO:-/repo}"

docker build \
  --build-arg LFRDEV_DOMAIN=${LFRDEV_DOMAIN} \
  -t dxp-server \
  ${REPO}/docker/images/dxp-server
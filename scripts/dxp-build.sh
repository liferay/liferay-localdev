#!/usr/bin/env bash

set -ex

IMAGE=dxp-server

REPO="${LOCALDEV_REPO:-/repo}"

docker build \
  --build-arg CUST_CODE=${CUST_CODE} \
  -t dxp-server \
  ${REPO}/docker/images/dxp-server
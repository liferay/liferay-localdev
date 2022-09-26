#!/usr/bin/env bash

set -e

docker build \
  -t dxp-server \
  /repo/docker/images/dxp-server
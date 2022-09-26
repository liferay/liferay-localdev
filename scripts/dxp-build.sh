#!/usr/bin/env bash

set -e

docker build \
  -t dxp-localdev \
  /repo/docker/images/dxp-localdev
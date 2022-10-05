#!/usr/bin/env bash

set -ex

IMAGE=dxp-server

if [ -z "$LOCALDEV_REPO" ]; then
  echo "Must specify LOCALDEV_REPO env var"
  exit 1
fi

EXISTING_DXP_SERVER=$(docker ps -f name=dxp-server | grep dxp-server | awk '{print $1}')

if [ -z "$EXISTING_DXP_SERVER" ]; then
  echo "dxp-server is not running."
  exit 1
fi

STATUS=$(docker exec -i dxp-server curl -s http://127.0.0.1:8080/health | jq -r '.status')

if [ "$STATUS" != "UP" ]; then
  echo "dxp-server is not up yet."
  exit 1
fi
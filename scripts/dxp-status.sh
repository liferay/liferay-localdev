#!/usr/bin/env bash

set -ex

IMAGE=dxp-server

EXISTING_DXP_SERVER=$(docker ps -f name=dxp-server | grep dxp-server | awk '{print $1}')

if [ -z "$EXISTING_DXP_SERVER" ]; then
	echo "dxp-server is not running."
	exit 1
fi

STATUS=$(docker exec -i dxp-server curl -m 1 -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8080/c/portal/robots)

if [ "$STATUS" != "200" ]; then
	echo "dxp-server is not up yet."
	exit 1
fi
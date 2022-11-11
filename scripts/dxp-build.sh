#!/usr/bin/env bash

set -ex

IMAGE=dxp-server

REPO="${LOCALDEV_REPO:-/repo}"
DXP_BUILDARGS="${DXP_BUILDARGS:-}"

docker build \
	--build-arg LFRDEV_DOMAIN=${LFRDEV_DOMAIN} \
	${DXP_BUILDARGS} \
	-t dxp-server \
	${REPO}/docker/images/dxp-server
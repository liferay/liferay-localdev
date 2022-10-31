#!/usr/bin/env bash

set -ex

IMAGE=dxp-server

REPO="${LOCALDEV_REPO:-/repo}"
MORE_DXP_BUILDARGS="${MORE_DXP_BUILDARGS:-}"

docker build \
	--build-arg LFRDEV_DOMAIN=${LFRDEV_DOMAIN} \
	${MORE_DXP_BUILDARGS} \
	-t dxp-server \
	${REPO}/docker/images/dxp-server
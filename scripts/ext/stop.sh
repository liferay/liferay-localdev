#!/usr/bin/env bash

set -e

REPO="${LOCALDEV_REPO:-/repo}"

CONTAINER=$(docker container list --format '{{json .}}' | jq -sr '.[] | select(.Names=="localdev-extension-runtime")')

if [ "$CONTAINER" == "" ]; then
	echo "'localdev' extension environment stopped."
	exit 0
fi

docker exec -i localdev-extension-runtime ${REPO}/scripts/ext/exec/stop.sh
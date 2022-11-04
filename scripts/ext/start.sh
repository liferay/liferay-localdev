#!/usr/bin/env bash

set -e

REPO="${LOCALDEV_REPO:-/repo}"

${REPO}/scripts/runtime/start.sh

if ${REPO}/scripts/ext/status.sh; then
	echo "'localdev' extension environment is already started."
	exit 0
fi

${REPO}/scripts/refresh-on-new-extension.sh /workspace/client-extensions &

export DO_NOT_TRACK=1

tilt up -f ${REPO}/tilt/Tiltfile $@

echo "'localdev' extension environment started."
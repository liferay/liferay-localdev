#!/usr/bin/env bash

set -e

REPO="${LOCALDEV_REPO:-/repo}"

export KUBECONFIG=$(k3d kubeconfig write localdev 2>/dev/null)

tilt down -f ${REPO}/tilt/Tiltfile

PID=$(pgrep -f "${REPO}/tilt/Tiltfile")
if [ "${PID}x" != "x" ]; then
    echo "forcefully terminating tilt process $PID"
    kill -KILL $PID
fi

echo "'localdev' extension environment is stopped."
#!/usr/bin/env bash

set -e

export LOCALDEV_REPO=/repo
export KUBECONFIG=$(k3d kubeconfig write localdev 2>/dev/null)

tilt down -f /repo/tilt/Tiltfile

PID=$(pgrep -f "/repo/tilt/Tiltfile")
if [ "${PID}x" != "x" ]; then
    echo "forcefully terminating tilt process $PID"
    kill -KILL $PID
fi

echo "'localdev' extension environment is stopped."
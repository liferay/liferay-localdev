#!/usr/bin/env bash

set -e

export KUBECONFIG=$(k3d kubeconfig write localdev 2>/dev/null)

PID=$(tilt get session -o json | jq -r '.items[] | select(.kind=="Session") | .status.pid' 2>/dev/null)
if [ "${PID}x" != "x" ]; then
    echo "'localdev' extension environment is started."
    exit 0
fi

echo "'localdev' extension environment is not started."
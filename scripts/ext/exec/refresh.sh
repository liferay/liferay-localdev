#!/usr/bin/env bash

set -e

export LOCALDEV_REPO=/repo
export KUBECONFIG=$(k3d kubeconfig write localdev 2>/dev/null)

tilt trigger "(Tiltfile)"

echo "'localdev' extension environment refreshed."
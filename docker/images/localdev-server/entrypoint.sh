#!/usr/bin/env bash

set -e

export LOCALDEV_REPO=${LOCALDEV_REPO:-/repo}
export KUBECONFIG=$(k3d kubeconfig write localdev 2>/dev/null)
export TILT_HOST=0.0.0.0

$@
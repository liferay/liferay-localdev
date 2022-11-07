#!/usr/bin/env bash

set -e

sudo chown "$LOCALDEV_USER" /var/run/docker.sock
sudo chown -R "$LOCALDEV_USER" /var/run/user

export LOCALDEV_REPO=${LOCALDEV_REPO:-/repo}
export KUBECONFIG=${KUBECONFIG:-$(k3d kubeconfig write localdev 2>/dev/null)}
export TILT_HOST=0.0.0.0

$@
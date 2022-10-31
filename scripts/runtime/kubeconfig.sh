#!/usr/bin/env bash

set -e

KUBECONFIG="${KUBECONFIG:-/var/run/.kube/config}"

k3d \
	kubeconfig merge localdev \
	--kubeconfig-merge-default \
	--kubeconfig-switch-context 1> /dev/null

echo "Successfully merge localdev config and set default context into {HOME}/.kube/config"
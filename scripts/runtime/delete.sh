#!/usr/bin/env bash

set -e

REPO="${LOCALDEV_REPO:-/repo}"

${REPO}/scripts/runtime/stop.sh

k3d cluster delete localdev

echo "'localdev' runtime environment deleted."
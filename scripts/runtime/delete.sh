#!/usr/bin/env bash

set -e

k3d cluster delete localdev

docker container rm -f dxp-server localdev-dnsmasq localdev-extension-runtime >/dev/null 2>&1

echo "'localdev' runtime environment deleted."
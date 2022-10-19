#!/usr/bin/env bash

set -ex

set +e
RS=$(docker container stop dxp-server localdev-dnsmasq >/dev/null 2>&1)

echo "'dxp-server' 'localdev-dnsmasq' stopped."
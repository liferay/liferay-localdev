#!/usr/bin/env bash

RS=$(docker container stop dxp-server localdev-dnsmasq >/dev/null 2>&1)

echo "'dxp-server' 'localdev-dnsmasq' stopped."
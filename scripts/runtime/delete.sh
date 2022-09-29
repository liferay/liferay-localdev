#!/usr/bin/env bash

set -e

k3d cluster delete localdev

docker container rm -f localdev-dnsmasq
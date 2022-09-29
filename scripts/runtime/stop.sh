#!/usr/bin/env bash

set -e

k3d cluster stop localdev

docker container stop localdev-dnsmasq
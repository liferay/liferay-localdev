#!/usr/bin/env bash

set -ex

docker run \
  --name localdev-dnsmasq \
  --network k3d-localdev \
  --rm \
  --entrypoint dnsmasq \
  dnsmasq \
  -d
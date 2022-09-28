#!/usr/bin/env bash

set -ex

docker run \
  --name dnsmasq-start \
  --network k3d-localdev \
  --rm \
  --entrypoint dnsmasq \
  dnsmasq \
  -d
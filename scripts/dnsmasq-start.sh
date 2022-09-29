#!/usr/bin/env bash

set -e

# start dnsmasq and detach it to the background
# this will to route all '*.localdev.me' hosts to local network gateway (traefik)
docker run \
  -d \
  --name localdev-dnsmasq \
  --network k3d-localdev \
  --rm \
  localdev-dnsmasq
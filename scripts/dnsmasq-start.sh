#!/usr/bin/env bash

set -e

CONTAINER=$(docker container list --format '{{json .}}' | jq -sr '.[] | select(.Names=="localdev-dnsmasq")')

if [ "$CONTAINER" != "" ]; then
    echo "'localdev' dnsmasq service is running."
    exit 0
fi

docker build \
  -t localdev-dnsmasq \
  ${REPO}/docker/images/localdev-dnsmasq

# start dnsmasq and detach it to the background
# this will to route all '*.localdev.me' hosts to local network gateway (traefik)
docker run \
  -d \
  --name localdev-dnsmasq \
  --network k3d-localdev \
  --rm \
  localdev-dnsmasq

echo "'localdev' dnsmasq service is running."
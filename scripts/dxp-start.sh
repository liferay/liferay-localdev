#!/usr/bin/env bash

set -ex

IMAGE=dxp-server

if [ -z "$LOCALDEV_REPO" ]; then
  echo "Must specify LOCALDEV_REPO env var"
  exit 1
fi

KUBERNETES_CERTIFICATE=$(/repo/scripts/k8s-certificate.sh)
KUBERNETES_TOKEN=$(/repo/scripts/k8s-token.sh)

# find the IP address of the dnsmasq container
DNS_ADDRESS=$(\
  docker network inspect k3d-localdev | \
    jq --raw-output '.[0].Containers[] | select(.Name=="localdev-dnsmasq") | .IPv4Address' | \
    cut -d'/' -f1)

docker run \
  --name ${IMAGE} \
  --dns $DNS_ADDRESS \
  --network k3d-localdev \
  --rm \
  -v liferayData:/opt/liferay/data:rw \
  -p 8000:8000 \
  -p 8080:8080 \
  -p 11311:11311 \
  -e KUBERNETES_SERVICE_HOST=k3d-localdev-server-0 \
  -e KUBERNETES_SERVICE_PORT=6443 \
  -e KUBERNETES_NAMESPACE=default \
  -e KUBERNETES_CERTIFICATE="$KUBERNETES_CERTIFICATE" \
  -e KUBERNETES_TOKEN="$KUBERNETES_TOKEN" \
  $IMAGE

#!/usr/bin/env bash

set -ex

IMAGE=dxp-server

REPO="${LOCALDEV_REPO:-/repo}"

EXISTING_DXP_SERVER=$(docker ps -f name=dxp-server | grep dxp-server | awk '{print $1}')

if [ ! -z "$EXISTING_DXP_SERVER" ]; then
  docker container rm -f $EXISTING_DXP_SERVER

  EXISTING_DXP_SERVER=$(docker ps -f name=dxp-server | grep dxp-server | awk '{print $1}')
  if [ ! -z "$EXISTING_DXP_SERVER" ]; then
    echo "Existing dxp-server container still running, please stop $EXISTING_DXP_SERVER before restarting."
    exit 1
  fi
fi

KUBERNETES_CERTIFICATE=$(${REPO}/scripts/k8s-certificate.sh)
KUBERNETES_TOKEN=$(${REPO}/scripts/k8s-token.sh)

# ensure the dnsmasq server has been started
${REPO}/scripts/dnsmasq-start.sh

# find the IP address of the dnsmasq container
DNS_ADDRESS=$(\
  docker network inspect k3d-localdev | \
    jq --raw-output '.[0].Containers[] | select(.Name=="localdev-dnsmasq") | .IPv4Address' | \
    cut -d'/' -f1)

docker run \
  --name ${IMAGE} \
  --dns ${DNS_ADDRESS} \
  --network k3d-localdev \
  --rm \
  -v liferayData:/opt/liferay/data:rw \
  -p 8000:8000 \
  -p 18081:8080 \
  -p 11311:11311 \
  -e KUBERNETES_SERVICE_HOST=k3d-localdev-server-0 \
  -e KUBERNETES_SERVICE_PORT=6443 \
  -e KUBERNETES_NAMESPACE=default \
  -e KUBERNETES_CERTIFICATE="$KUBERNETES_CERTIFICATE" \
  -e KUBERNETES_TOKEN="$KUBERNETES_TOKEN" \
  -e LFRDEV_DOMAIN="$LFRDEV_DOMAIN" \
  $IMAGE
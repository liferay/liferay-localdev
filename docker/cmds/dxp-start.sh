#!/usr/bin/env bash

set -xe

CLIENT_EXTENSIONS_DEPLOY_PATH=$1
DEPLOY_PATH=$2
ADD_HOST=$3
#ADD_HOST=coupon-action-springboot.localdev.me:172.150.0.1
IMAGE=dxp-lxc-localdev

KUBERNETES_CERTIFICATE=$(./lxc-localdev-cmd.sh /repo/scripts/k8s-certificate.sh)
KUBERNETES_TOKEN=$(./lxc-localdev-cmd.sh /repo/scripts/k8s-token.sh)

docker run \
  -v "$CLIENT_EXTENSIONS_DEPLOY_PATH:/opt/liferay/osgi/client-extensions" \
  -v "$DEPLOY_PATH:/mnt/liferay/deploy" \
  -v liferayData:/opt/liferay/data:rw \
  -p 8000:8000 \
  -p 8080:8080 \
  -p 11311:11311 \
  -e KUBERNETES_SERVICE_HOST=k3d-lxc-localdev-server-0 \
  -e KUBERNETES_SERVICE_PORT=6443 \
  -e KUBERNETES_NAMESPACE=default \
  -e KUBERNETES_CERTIFICATE="$KUBERNETES_CERTIFICATE" \
  -e KUBERNETES_TOKEN="$KUBERNETES_TOKEN" \
  --add-host "$ADD_HOST" \
  --network k3d-lxc-localdev \
  $IMAGE
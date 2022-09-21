#!/usr/bin/env bash

set -ex

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

#ADD_HOST=coupon-action-springboot.localdev.me:172.150.0.1
IMAGE=dxp-lxc-localdev

if [ -z "$LOCALDEV_REPO" ]; then
  echo "Must specify LOCALDEV_REPO env var"
  exit 1
fi


if [ -z "$ADD_HOST" ]; then
  echo "Must specify ADD_HOST env var"
  exit 1
fi

KUBERNETES_CERTIFICATE=$($SCRIPT_DIR/lxc-localdev-cmd.sh /repo/scripts/k8s-certificate.sh)
KUBERNETES_TOKEN=$($SCRIPT_DIR/lxc-localdev-cmd.sh /repo/scripts/k8s-token.sh)

docker run \
  --name ${IMAGE}-runner \
  --rm \
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
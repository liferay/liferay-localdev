#!/usr/bin/env bash

set -ex

IMAGE=dxp-server

if [ -z "$LOCALDEV_REPO" ]; then
  echo "Must specify LOCALDEV_REPO env var"
  exit 1
fi

KUBERNETES_CERTIFICATE=$(/repo/scripts/k8s-certificate.sh)
KUBERNETES_TOKEN=$(/repo/scripts/k8s-token.sh)

# For every client-extension that has a type of oauthApplication* we need to emit a hosts file entry into docker container pointing to gateway
CLIENT_EXTENSION_YAMLS=$(find /workspace/client-extensions -name client-extension.yaml -not -path **/build/** -not -path **/node_modules/**)

function_hosts=

for client_extension_yaml in $CLIENT_EXTENSION_YAMLS; do
  needs_host=$(cat $client_extension_yaml | yq e 'to_entries | .[] | select(.value.type | test("oauthApplication.*")) | .key')
  if [ ! -z $needs_host  ]; then
    sub_domain=$(basename $(dirname $client_extension_yaml))
    function_hosts+=("${sub_domain}.localdev.me:172.150.0.1")
  fi
done

ADD_HOSTS_ARGS=

for function_host in ${function_hosts[@]}; do
  ADD_HOST_ARGS="$ADD_HOST_ARGS --add-host ${function_host}"
done

docker run \
  --name ${IMAGE} \
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
  $ADD_HOST_ARGS \
  $IMAGE

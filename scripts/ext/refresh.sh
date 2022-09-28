#!/usr/bin/env bash

set -e

# For every client-extension that has a type of oauthApplication* we need to emit a hosts file entry into docker container pointing to gateway
CLIENT_EXTENSION_YAMLS=$(find /workspace/client-extensions -name client-extension.yaml -not -path **/build/** -not -path **/node_modules/**)

function_hosts=

for client_extension_yaml in $CLIENT_EXTENSION_YAMLS; do
  needs_host=$(cat $client_extension_yaml | yq e 'to_entries | .[] | select(.value.type | test("oauthApplication.*")) | .key')
  if [ ! -z $needs_host  ]; then
    sub_domain=$(basename $(dirname $client_extension_yaml))
    function_hosts+=("172.150.0.1 ${sub_domain}.localdev.me")
  fi
done

for function_host in ${function_hosts[@]}; do
  docker exec dxp-server echo "${function_host}" >> /etc/hosts
done

tilt trigger "(Tiltfile)" --host host.docker.internal
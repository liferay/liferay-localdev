#!/usr/bin/env bash

set -e

if [ -z "$LOCALDEV_REPO" ]; then
  echo "Must specify LOCALDEV_REPO env var"
  exit 1
fi

docker build \
  -t localdev-server-test \
  ${LOCALDEV_REPO}/docker/images/localdev-server

rm -rf ../work/

git clone --depth 1 https://github.com/gamerson/gartner-client-extensions-demo ../work/gartner-client-extensions-demo

(docker run \
  --rm \
  --name \
  localdev-test \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ${LOCALDEV_REPO}:/repo \
  -v ${LOCALDEV_REPO}/tests/work/gartner-client-extensions-demo:/workspace/client-extensions \
  -v localdevGradleCache:/root/.gradle \
  -v localdevLiferayCache:/root/.liferay \
  localdev-server \
  /repo/scripts/ext/start.sh) &

FOUND_CONFIG_MAPS=0

echo "FOUND_CONFIG_MAPS: $FOUND_CONFIG_MAPS"
until [ "$FOUND_CONFIG_MAPS" == "4" ]; do
  FOUND_CONFIG_MAPS=$(docker exec -i localdev-test /entrypoint.sh kubectl get cm | grep ext-init-metadata | wc -l | xargs)
  sleep 5
done

docker kill localdev-test dxp-server
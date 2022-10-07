#!/usr/bin/env bash

set -e

if [ -z "$LOCALDEV_REPO" ]; then
  echo "Must specify LOCALDEV_REPO env var"
  exit 1
fi

docker build \
  -t localdev-server-test \
  ${LOCALDEV_REPO}/docker/images/localdev-server

rm -rf ${LOCALDEV_REPO}/tests/work/

git clone --depth 1 https://github.com/gamerson/gartner-client-extensions-demo ${LOCALDEV_REPO}/tests/work/gartner-client-extensions-demo

(docker run \
  --rm \
  --name \
  localdev-test-start \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ${LOCALDEV_REPO}:/repo \
  -v ${LOCALDEV_REPO}/tests/work/gartner-client-extensions-demo:/workspace/client-extensions \
  -v localdevGradleCache:/root/.gradle \
  -v localdevLiferayCache:/root/.liferay \
  localdev-server \
  /repo/scripts/ext/start.sh) &

FOUND_CONFIG_MAPS=0

until [ "$FOUND_CONFIG_MAPS" == "4" ]; do
  FOUND_CONFIG_MAPS=$(docker exec -i localdev-test-start /entrypoint.sh kubectl get cm | grep ext-init-metadata | wc -l | xargs)
  sleep 5
done

docker run \
  --rm \
  --name \
  localdev-test-stop \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ${LOCALDEV_REPO}:/repo \
  -v ${LOCALDEV_REPO}/tests/work/gartner-client-extensions-demo:/workspace/client-extensions \
  -v localdevGradleCache:/root/.gradle \
  -v localdevLiferayCache:/root/.liferay \
  localdev-server \
  /repo/scripts/ext/stop.sh

docker container rm -f dxp-server
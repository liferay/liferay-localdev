#!/usr/bin/env bash

set -e

if [ -z "$LOCALDEV_REPO" ]; then
  echo "Must specify LOCALDEV_REPO env var"
  exit 1
fi

if [ -z "$DOCKER_NETWORK" ]; then
  echo "Must specify DOCKER_NETWORK env var"
  exit 1
fi

docker build \
  -t localdev-server-test \
  ${LOCALDEV_REPO}/docker/images/localdev-server

docker build \
  -t localdev-dnsmasq \
  ${LOCALDEV_REPO}/docker/images/localdev-dnsmasq

rm -rf ${LOCALDEV_REPO}/tests/work/

git clone \
  --branch frontendClientExtensions \
  --depth 1 https://github.com/gamerson/gartner-client-extensions-demo \
  ${LOCALDEV_REPO}/tests/work/gartner-client-extensions-demo

(docker run \
  --rm \
  --name localdev-server-test-start \
  --network ${DOCKER_NETWORK} \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ${LOCALDEV_REPO}:/repo \
  -v ${LOCALDEV_REPO}/tests/work/gartner-client-extensions-demo:/workspace/client-extensions \
  -v localdevGradleCache:/root/.gradle \
  -v localdevLiferayCache:/root/.liferay \
  localdev-server-test \
  /repo/scripts/ext/start.sh) &

FOUND_EXT_PROVISION_CONFIG_MAPS=0

until [ "$FOUND_EXT_PROVISION_CONFIG_MAPS" == "7" ]; do
  sleep 1
  FOUND_EXT_PROVISION_CONFIG_MAPS=$(docker exec -i localdev-server-test-start /entrypoint.sh kubectl get cm | grep ext-provision-metadata | wc -l | xargs)
  echo "FOUND_EXT_PROVISION_CONFIG_MAPS=${FOUND_EXT_PROVISION_CONFIG_MAPS}"
done

FOUND_EXT_INIT_CONFIG_MAPS=0

until [ "$FOUND_EXT_INIT_CONFIG_MAPS" == "4" ]; do
  sleep 1
  FOUND_EXT_INIT_CONFIG_MAPS=$(docker exec -i localdev-server-test-start /entrypoint.sh kubectl get cm | grep ext-init-metadata | wc -l | xargs)
  echo "FOUND_EXT_INIT_CONFIG_MAPS=${FOUND_EXT_INIT_CONFIG_MAPS}"
done

docker run \
  --rm \
  --name localdev-runtime-delete \
  --network ${DOCKER_NETWORK} \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ${LOCALDEV_REPO}:/repo \
  localdev-server-test \
  /repo/scripts/runtime/delete.sh

docker container rm \
  -f \
  localdev-server-test-start
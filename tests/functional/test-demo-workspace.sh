#!/usr/bin/env bash

set -e

LIFERAY_CLI_BRANCH="buildNetworkMode"

mkdir -p ${LOCALDEV_REPO}/tests/work/

if [ "$LIFERAY_CLI_BRANCH" != "" ]; then
  git clone \
    --branch main \
    --depth 1 \
    https://github.com/liferay/liferay-cli \
    ${LOCALDEV_REPO}/tests/work/liferay

  cd ${LOCALDEV_REPO}/tests/work/liferay

  CLI="./gow run main.go"
else
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/liferay/liferay-cli/HEAD/install.sh)"

  CLI="liferay"
fi

$CLI config set localdev.resources.dir ${LOCALDEV_REPO}

$CLI config set localdev.resources.sync false

$CLI runtime mkcert

$CLI runtime mkcert --install

git clone \
  --branch tiltImprovements1 \
  --depth 1 \
  https://github.com/gamerson/gartner-client-extensions-demo \
  ${LOCALDEV_REPO}/tests/work/gartner-client-extensions-demo

$CLI runtime create -v

$CLI ext start -d ${LOCALDEV_REPO}/tests/work/gartner-client-extensions-demo

FOUND_LOCALDEV_SERVER=0

until [ "$FOUND_LOCALDEV_SERVER" == "1" ]; do
  sleep 5
  FOUND_LOCALDEV_SERVER=$(docker ps | grep localdev-extension-runtime | wc -l)
  echo "FOUND_LOCALDEV_SERVER=${FOUND_LOCALDEV_SERVER}"
done

FOUND_EXT_PROVISION_CONFIG_MAPS=0

until [ "$FOUND_EXT_PROVISION_CONFIG_MAPS" == "4" ]; do
  sleep 5
  FOUND_EXT_PROVISION_CONFIG_MAPS=$(docker exec -i localdev-extension-runtime /entrypoint.sh kubectl get cm | grep ext-provision-metadata | wc -l | xargs)
  echo "FOUND_EXT_PROVISION_CONFIG_MAPS=${FOUND_EXT_PROVISION_CONFIG_MAPS}"
  docker logs -n 100 localdev-extension-runtime
done

FOUND_EXT_INIT_CONFIG_MAPS=0

until [ "$FOUND_EXT_INIT_CONFIG_MAPS" == "4" ]; do
  sleep 5
  FOUND_EXT_INIT_CONFIG_MAPS=$(docker exec -i localdev-extension-runtime /entrypoint.sh kubectl get cm | grep ext-init-metadata | wc -l | xargs)
  echo "FOUND_EXT_INIT_CONFIG_MAPS=${FOUND_EXT_INIT_CONFIG_MAPS}"
  docker logs -n 100 localdev-extension-runtime
done

$CLI runtime delete
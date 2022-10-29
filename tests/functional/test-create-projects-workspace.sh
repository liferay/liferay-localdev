#!/usr/bin/env bash

set -e

LIFERAY_CLI_BRANCH=""

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

BASE_PATH=${LOCALDEV_REPO}/tests/work/workspace/client-extensions

mkdir -p $BASE_PATH

export WORKSPACE_BASE_PATH="$BASE_PATH"
export BUILD_PROJECTS="false"

../integration/test-create-projects.sh

$CLI ext start -d $BASE_PATH

FOUND_LOCALDEV_SERVER=0

until [ "$FOUND_LOCALDEV_SERVER" == "1" ]; do
  sleep 5
  FOUND_LOCALDEV_SERVER=$(docker ps | grep localdev-extension-runtime | wc -l)
  echo "FOUND_LOCALDEV_SERVER=${FOUND_LOCALDEV_SERVER}"
done

FOUND_EXT_PROVISION_CONFIG_MAPS=0

until [ "$FOUND_EXT_PROVISION_CONFIG_MAPS" == "10" ]; do
  sleep 5
  FOUND_EXT_PROVISION_CONFIG_MAPS=$(docker exec -i localdev-extension-runtime /entrypoint.sh kubectl get cm | grep ext-provision-metadata | wc -l | xargs)
  echo "FOUND_EXT_PROVISION_CONFIG_MAPS=${FOUND_EXT_PROVISION_CONFIG_MAPS}"
  docker logs -n 100 localdev-extension-runtime
done

FOUND_EXT_INIT_CONFIG_MAPS=0

until [ "$FOUND_EXT_INIT_CONFIG_MAPS" == "3" ]; do
  sleep 5
  FOUND_EXT_INIT_CONFIG_MAPS=$(docker exec -i localdev-extension-runtime /entrypoint.sh kubectl get cm | grep ext-init-metadata | wc -l | xargs)
  echo "FOUND_EXT_INIT_CONFIG_MAPS=${FOUND_EXT_INIT_CONFIG_MAPS}"
  docker logs -n 100 localdev-extension-runtime
done

$CLI runtime delete
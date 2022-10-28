#!/usr/bin/env bash

set -e

LIFERAY_CLI_BRANCH=""

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

$CLI ext create \
  --workspace-path static/able-global-css \
  --resource-path template/global-css \
  --args id=able \
  --args "name=Able Global CSS"

$CLI ext create \
  --workspace-path static/baker-global-css \
  --resource-path template/global-css \
  --args id=baker \
  --args "name=Baker Global CSS"

$CLI ext create \
  --workspace-path foo-configuration \
  --resource-path template/configuration \
  --args id=foo \
  --args "name=Foo Configuration"

$CLI ext create \
  --workspace-path service/test-springboot-service \
  --resource-path template/service-springboot \
  --args package=com.liferay.test \
  --args packagePath=com/liferay/test

$CLI ext create \
  --workspace-path foo-nodejs-service \
  --resource-path template/service-nodejs \
  --args id=foo \
  --args "name=Foo Service"

$CLI ext build

ZIP_FILE_COUNT=$(find "${WORKSPACE_BASE_PATH}" -name '*.zip' | wc -l | awk '{print $1}' )

if [ "$ZIP_FILE_COUNT" != "5" ]; then
  echo "ZIP_FILE_COUNT=$ZIP_FILE_COUNT expected 5"
  exit 1
fi
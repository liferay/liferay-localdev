#!/usr/bin/env bash

set -e

export RESOURCES_BASE_PATH="${LOCALDEV_REPO}/resources/"
export WORKSPACE_BASE_PATH="${LOCALDEV_REPO}/tests/work/"
BUILD_CMD=${LOCALDEV_REPO}/scripts/ext/build.sh
CREATE_CMD=${LOCALDEV_REPO}/scripts/ext/create.py

rm -rf $WORKSPACE_BASE_PATH && mkdir -p $WORKSPACE_BASE_PATH

$CREATE_CMD \
  --workspace-path=static/able-global-css \
  --resource-path=template/global-css \
  id=able \
  name="Able Global CSS"

$CREATE_CMD \
  --workspace-path=static/baker-global-css \
  --resource-path=template/global-css \
  id=baker \
  name="Baker Global CSS"

$CREATE_CMD \
  --workspace-path=foo-configuration \
  --resource-path=template/configuration \
  id=foo \
  name="Foo Configuration"

$CREATE_CMD \
  --workspace-path=service/test-springboot-service \
  --resource-path=template/service-springboot \
  package=com.liferay.test \
  packagePath="com/liferay/test"

$CREATE_CMD \
  --workspace-path=foo-nodejs-service \
  --resource-path=template/service-nodejs \
  id=foo \
  name="Foo Service"
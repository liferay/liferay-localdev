#!/usr/bin/env bash

set -e

export RESOURCES_BASE_PATH="${LOCALDEV_REPO}/resources/"
export WORK_PATH="${LOCALDEV_REPO}/tests/work"
export WORKSPACE_BASE_PATH="${WORK_PATH}/workspace/client-extensions"
BUILD_CMD=${LOCALDEV_REPO}/scripts/ext/build.sh
CREATE_CMD=${LOCALDEV_REPO}/scripts/ext/create.py

rm -rf $WORK_PATH && mkdir -p $WORK_PATH

cp -R "${LOCALDEV_REPO}/docker/images/localdev-server/workspace" "${WORK_PATH}"
mkdir -p "${WORK_PATH}/workspace/client-extensions"

$CREATE_CMD \
  --workspace-path=static/able-global-css \
  --resource-path=template/global-css \
  --template-args="id=able" \
  --template-args="name=Able Global CSS"

#$CREATE_CMD \
  #--workspace-path=static/baker-global-css \
  #--resource-path=template/global-css \
  #id=baker \
  #name="Baker Global CSS"
#
#$CREATE_CMD \
  #--workspace-path=foo-configuration \
  #--resource-path=template/configuration \
  #id=foo \
  #name="Foo Configuration"
#
#$CREATE_CMD \
  #--workspace-path=service/test-springboot-service \
  #--resource-path=template/service-springboot \
  #package=com.liferay.test \
  #packagePath="com/liferay/test"
#
#$CREATE_CMD \
  #--workspace-path=foo-nodejs-service \
  #--resource-path=template/service-nodejs \
  #id=foo \
  #name="Foo Service"

#"${WORK_PATH}/workspace/gradlew" --project-dir "${WORK_PATH}/workspace" build

#ZIP_FILE_COUNT=$(find "${WORKSPACE_BASE_PATH}" -name '*.zip' | wc -l | awk '{print $1}' )
#
#if [ "$ZIP_FILE_COUNT" != "5" ]; then
  #echo "ZIP_FILE_COUNT=$ZIP_FILE_COUNT expected 5"
  #exit 1
#fi
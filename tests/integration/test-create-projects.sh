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

CREATE_ARGS="\
--workspace-path=casc/my-casc|\
--resource-path=template/configuration|\
--args=id=my-casc|\
--args=name=My Configuration as Code" $CREATE_CMD 

CREATE_ARGS="\
--workspace-path=static/baker-custom-element|\
--resource-path=template/custom-element|\
--args=id=baker-custom-element|\
--args=name=Baker Custom Element" $CREATE_CMD

CREATE_ARGS="\
--workspace-path=static/charlie-global-css|\
--resource-path=template/global-css|\
--args=id=charlie-global-css|\
--args=name=Charlie Global CSS" $CREATE_CMD 

CREATE_ARGS="\
--workspace-path=static/delta-global-js|\
--resource-path=template/global-js|\
--args=id=delta-global-js|\
--args=name=Delta Global JS" $CREATE_CMD 

CREATE_ARGS="\
--workspace-path=static/echo-iframe|\
--resource-path=template/iframe|\
--args=id=echo-iframe|\
--args=name=Echo iframe" $CREATE_CMD 

CREATE_ARGS="\
--workspace-path=static/fox-remote-app|\
--resource-path=template/remote-app-react|\
--args=id=fox-remote-app|\
--args=name=Fox Remote App" $CREATE_CMD

CREATE_ARGS="\
--workspace-path=service/gamma-nodejs-service|\
--resource-path=template/service-nodejs|\
--args=id=gamma-nodejs-service|\
--args=name=Gamma Nodejs Service" $CREATE_CMD

CREATE_ARGS="\
--workspace-path=service/hotel-springboot-service|\
--resource-path=template/service-springboot|\
--args=package=com.company.hotel|\
--args=packagePath=com/company/hotel" $CREATE_CMD

CREATE_ARGS="\
--workspace-path=static/india-theme-css|\
--resource-path=template/theme-css|\
--args=id=india-theme-css|\
--args=name=India Theme CSS" $CREATE_CMD

CREATE_ARGS="\
--workspace-path=static/juliet-theme-favicon|\
--resource-path=template/theme-favicon|\
--args=id=juliet-theme-favicon|\
--args=name=Juliet Theme Favicon" $CREATE_CMD

"${WORK_PATH}/workspace/gradlew" --project-dir "${WORK_PATH}/workspace" build

ZIP_FILE_COUNT=$(find "${WORKSPACE_BASE_PATH}" -name '*.zip' | wc -l | awk '{print $1}' )

if [ "$ZIP_FILE_COUNT" != "5" ]; then
  echo "ZIP_FILE_COUNT=$ZIP_FILE_COUNT expected 5"
  exit 1
fi
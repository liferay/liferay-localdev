#!/usr/bin/env bash

set -e

export RESOURCES_BASE_PATH="${LOCALDEV_REPO}/resources/"
export WORK_PATH="${LOCALDEV_REPO}/tests/work"
export WORKSPACE_BASE_PATH="${WORKSPACE_BASE_PATH:-${WORK_PATH}/workspace/client-extensions}"
BUILD_CMD=${LOCALDEV_REPO}/scripts/ext/build.sh
CREATE_CMD=${LOCALDEV_REPO}/scripts/ext/create.py
BUILD_PROJECTS=${BUILD_PROJECTS:-true}

rm -rf $WORK_PATH && mkdir -p $WORK_PATH

cp -R "${LOCALDEV_REPO}/tests/workspace" "${WORK_PATH}"
mkdir -p "${WORK_PATH}/workspace/client-extensions"

# Warning, these CREATE_ARGS are whitespace sensitive!

CREATE_ARGS="\
--workspace-path=casc/alpha-batch|\
--resource-path=template/batch|\
--args=id=alpha-batch|\
--args=name=Alpha Batch" $CREATE_CMD

CREATE_ARGS="\
--workspace-path=static/bravo-global-css|\
--resource-path=template/global-css|\
--args=id=bravo-global-css|\
--args=name=Bravo Global CSS" $CREATE_CMD

CREATE_ARGS="\
--workspace-path=static/charlie-global-js|\
--resource-path=template/global-js|\
--args=id=charlie-global-js|\
--args=name=Charlie Global JS" $CREATE_CMD

CREATE_ARGS="\
--workspace-path=static/delta-iframe|\
--resource-path=template/remote-app-iframe|\
--args=id=delta-iframe|\
--args=name=Delta iframe" $CREATE_CMD

CREATE_ARGS="\
--workspace-path=static/echo-remote-app|\
--resource-path=template/remote-app-react|\
--args=id=echo-remote-app|\
--args=name=Echo Remote App" $CREATE_CMD

CREATE_ARGS="\
--workspace-path=static/fox-remote-app|\
--resource-path=template/remote-app-vanilla|\
--args=id=fox-remote-app|\
--args=name=Fox Remote App" $CREATE_CMD

CREATE_ARGS="\
--workspace-path=service/golf-nodejs-service|\
--resource-path=template/service-nodejs|\
--args=id=golf-nodejs-service|\
--args=name=Golf Nodejs Service" $CREATE_CMD

CREATE_ARGS="\
--workspace-path=service/golf-nodejs-service|\
--resource-path=partial/object-action-nodejs|\
--args=id=myAction|\
--args=name=myAction|\
--args=Object=Foo|\
--args=resourcePath=/object/action" $CREATE_CMD

CREATE_ARGS="\
--workspace-path=service/hotel-springboot-service|\
--resource-path=template/service-springboot|\
--args=package=com.company.hotel|\
--args=packagePath=com/company/hotel" $CREATE_CMD

CREATE_ARGS="\
--workspace-path=service/hotel-springboot-service|\
--resource-path=partial/object-action-springboot|\
--args=actionName=myObjectAction|\
--args=id=my-object-action|\
--args=Object=Foo|\
--args=package=com.company.hotel|\
--args=packagePath=com/company/hotel|\
--args=resourcePath=/object/action" $CREATE_CMD

CREATE_ARGS="\
--workspace-path=service/hotel-springboot-service|\
--resource-path=partial/workflow-action-springboot|\
--args=actionName=myWorkflowAction|\
--args=id=my-workflow-action|\
--args=package=com.company.hotel|\
--args=packagePath=com/company/hotel|\
--args=resourcePath=/workflow/action" $CREATE_CMD

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

CREATE_ARGS="\
--workspace-path=static/juliet-theme-spritemap|\
--resource-path=template/theme-spritemap|\
--args=id=juliet-theme-spritemap|\
--args=name=Juliet Theme Spritemap" $CREATE_CMD

CREATE_ARGS="\
--workspace-path=service/kilo-springboot-service|\
--resource-path=template/service-springboot|\
--args=package=com.company.kilo|\
--args=packagePath=com/company/kilo" $CREATE_CMD

CREATE_ARGS="\
--workspace-path=service/kilo-springboot-service|\
--resource-path=partial/workflow-action-springboot|\
--args=actionName=myAction|\
--args=package=com.company.kilo|\
--args=packagePath=com/company/kilo|\
--args=resourcePath=/workflow/action" $CREATE_CMD

if [ "$BUILD_PROJECTS" == "true" ]; then
	"${WORK_PATH}/workspace/gradlew" --project-dir "${WORK_PATH}/workspace" --stacktrace build

	ZIP_FILE_COUNT=$(find "${WORKSPACE_BASE_PATH}" -name '*.zip' | wc -l | awk '{print $1}' )

	if [ "$ZIP_FILE_COUNT" != "12" ]; then
		echo "ZIP_FILE_COUNT=$ZIP_FILE_COUNT expected 12"
		exit 1
	fi
fi
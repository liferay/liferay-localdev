#!/usr/bin/env bash

set -e

export RESOURCES_BASE_PATH="${LOCALDEV_REPO}/resources/"
export WORK_PATH="${LOCALDEV_REPO}/tests/work"
export WORKSPACE_PATH="${WORK_PATH}/workspace"
BUILD_CMD=${LOCALDEV_REPO}/scripts/ext/build.sh
CREATE_CMD=${LOCALDEV_REPO}/scripts/ext/create.py
BUILD_PROJECTS=${BUILD_PROJECTS:-true}

rm -rf $WORK_PATH && mkdir -p $WORK_PATH

cp -R "${LOCALDEV_REPO}/tests/workspace" "${WORK_PATH}"
mkdir -p "${WORK_PATH}/workspace/client-extensions"

# Warning, these CREATE_ARGS are whitespace sensitive!

CREATE_ARGS="\
--project-path=client-extensions/casc/alpha-batch|\
--resource-path=template/batch|\
--workspace-path=${WORKSPACE_PATH}|\
--args=id=alpha-batch|\
--args=name=Alpha Batch" $CREATE_CMD

CREATE_ARGS="\
--project-path=client-extensions/static/bravo-global-css|\
--resource-path=template/global-css|\
--workspace-path=${WORKSPACE_PATH}|\
--args=id=bravo-global-css|\
--args=name=Bravo Global CSS" $CREATE_CMD

CREATE_ARGS="\
--project-path=client-extensions/static/charlie-global-js|\
--resource-path=template/global-js|\
--workspace-path=${WORKSPACE_PATH}|\
--args=id=charlie-global-js|\
--args=name=Charlie Global JS" $CREATE_CMD

CREATE_ARGS="\
--project-path=client-extensions/static/delta-iframe|\
--resource-path=template/remote-app-iframe|\
--workspace-path=${WORKSPACE_PATH}|\
--args=id=delta-iframe|\
--args=name=Delta iframe" $CREATE_CMD

CREATE_ARGS="\
--project-path=client-extensions/static/echo-remote-app|\
--resource-path=template/remote-app-react|\
--workspace-path=${WORKSPACE_PATH}|\
--args=id=echo-remote-app|\
--args=name=Echo Remote App" $CREATE_CMD

CREATE_ARGS="\
--project-path=client-extensions/static/fox-remote-app|\
--resource-path=template/remote-app-vanilla|\
--workspace-path=${WORKSPACE_PATH}|\
--args=id=fox-remote-app|\
--args=name=Fox Remote App" $CREATE_CMD

CREATE_ARGS="\
--project-path=client-extensions/service/golf-nodejs-service|\
--resource-path=template/service-nodejs|\
--workspace-path=${WORKSPACE_PATH}|\
--args=id=golf-nodejs-service|\
--args=name=Golf Nodejs Service" $CREATE_CMD

CREATE_ARGS="\
--project-path=client-extensions/service/golf-nodejs-service|\
--resource-path=partial/object-action-nodejs|\
--workspace-path=${WORKSPACE_PATH}|\
--args=id=myAction|\
--args=name=myAction|\
--args=Object=Foo|\
--args=resourcePath=/object/action" $CREATE_CMD

CREATE_ARGS="\
--project-path=client-extensions/service/hotel-springboot-service|\
--resource-path=template/service-springboot|\
--workspace-path=${WORKSPACE_PATH}|\
--args=package=com.company.hotel|\
--args=packagePath=com/company/hotel" $CREATE_CMD

CREATE_ARGS="\
--project-path=client-extensions/service/hotel-springboot-service|\
--resource-path=partial/object-action-springboot|\
--workspace-path=${WORKSPACE_PATH}|\
--args=actionName=myObjectAction|\
--args=id=my-object-action|\
--args=Object=Foo|\
--args=package=com.company.hotel|\
--args=packagePath=com/company/hotel|\
--args=resourcePath=/object/action" $CREATE_CMD

CREATE_ARGS="\
--project-path=client-extensions/service/hotel-springboot-service|\
--resource-path=partial/workflow-action-springboot|\
--workspace-path=${WORKSPACE_PATH}|\
--args=actionName=myWorkflowAction|\
--args=id=my-workflow-action|\
--args=package=com.company.hotel|\
--args=packagePath=com/company/hotel|\
--args=resourcePath=/workflow/action" $CREATE_CMD

CREATE_ARGS="\
--project-path=client-extensions/static/india-theme-css|\
--resource-path=template/theme-css|\
--workspace-path=${WORKSPACE_PATH}|\
--args=id=india-theme-css|\
--args=name=India Theme CSS" $CREATE_CMD

CREATE_ARGS="\
--project-path=client-extensions/static/juliet-theme-favicon|\
--resource-path=template/theme-favicon|\
--workspace-path=${WORKSPACE_PATH}|\
--args=id=juliet-theme-favicon|\
--args=name=Juliet Theme Favicon" $CREATE_CMD

CREATE_ARGS="\
--project-path=client-extensions/static/juliet-theme-spritemap|\
--resource-path=template/theme-spritemap|\
--workspace-path=${WORKSPACE_PATH}|\
--args=id=juliet-theme-spritemap|\
--args=name=Juliet Theme Spritemap" $CREATE_CMD

CREATE_ARGS="\
--project-path=client-extensions/service/kilo-springboot-service|\
--resource-path=template/service-springboot|\
--workspace-path=${WORKSPACE_PATH}|\
--args=package=com.company.kilo|\
--args=packagePath=com/company/kilo" $CREATE_CMD

CREATE_ARGS="\
--project-path=client-extensions/service/kilo-springboot-service|\
--resource-path=partial/workflow-action-springboot|\
--workspace-path=${WORKSPACE_PATH}|\
--args=actionName=myAction|\
--args=package=com.company.kilo|\
--args=packagePath=com/company/kilo|\
--args=resourcePath=/workflow/action" $CREATE_CMD

if [ "$BUILD_PROJECTS" == "true" ]; then
	"${WORK_PATH}/workspace/gradlew" --project-dir "${WORK_PATH}/workspace" --stacktrace build

	ZIP_FILE_COUNT=$(find "${WORKSPACE_PATH}" -name '*.zip' | wc -l | awk '{print $1}' )

	if [ "$ZIP_FILE_COUNT" != "12" ]; then
		echo "ZIP_FILE_COUNT=$ZIP_FILE_COUNT expected 12"
		exit 1
	fi
fi
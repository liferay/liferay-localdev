#!/usr/bin/env bash

set -e

LIFERAY_CLI_BRANCH="next"

if [ "$LIFERAY_CLI_BRANCH" != "" ]; then
	git clone \
		--branch $LIFERAY_CLI_BRANCH \
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

$CLI ext create \
	-d ${WORKSPACE_BASE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/global-css" \
	--workspace-path="static/able-global-css" \
	--args=id="able-global-css" \
	--args=name="Able Global CSS"

$CLI ext create \
	-d ${WORKSPACE_BASE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/global-js" \
	--workspace-path="static/bravo-global-js" \
	--args=id="bravo-global-js" \
	--args=name="Bravo Global JS"

$CLI ext create \
	-d ${WORKSPACE_BASE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/remote-app-iframe" \
	--workspace-path="static/charlie-iframe" \
	--args=id="charlie-iframe" \
	--args=name="Charlie iframe"

$CLI ext create \
	-d ${WORKSPACE_BASE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/remote-app-react" \
	--workspace-path="static/delta-remote-app" \
	--args=id="delta-remote-app" \
	--args=name="Delta Remote App"

$CLI ext create \
	-d ${WORKSPACE_BASE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/remote-app-vanilla" \
	--workspace-path="static/echo-remote-app" \
	--args=id="echo-remote-app" \
	--args=name="Echo Remote App"

$CLI ext create \
	-d ${WORKSPACE_BASE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/theme-css" \
	--workspace-path="static/fox-theme-css" \
	--args=id="fox-theme-css" \
	--args=name="Fox Theme CSS"

$CLI ext create \
	-d ${WORKSPACE_BASE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/theme-favicon" \
	--workspace-path="static/golf-theme-favicon" \
	--args=id="golf-theme-favicon" \
	--args=Name="Golf Theme Favicon"

$CLI ext create \
	-d ${WORKSPACE_BASE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/theme-spritemap" \
	--workspace-path="static/hotel-theme-spritemap" \
	--args=id="hotel-theme-spritemap" \
	--args=Name="Hotel Theme Spritemap"

($CLI ext start -v -d ${WORKSPACE_BASE_PATH} | sed 's/^/localdev │ /') &

FOUND_LOCALDEV_SERVER=0
echo "testcheck │ FOUND_LOCALDEV_SERVER"

until [ "$FOUND_LOCALDEV_SERVER" == "1" ]; do
	sleep 5
	FOUND_LOCALDEV_SERVER=$(docker ps | grep localdev-extension-runtime | wc -l)
done

FOUND_EXT_PROVISION_CONFIG_MAPS=0
echo "testcheck │ FOUND_EXT_PROVISION_CONFIG_MAPS"

until [ "$FOUND_EXT_PROVISION_CONFIG_MAPS" == "8" ]; do
	sleep 5
	FOUND_EXT_PROVISION_CONFIG_MAPS=$(docker exec -i localdev-extension-runtime /entrypoint.sh kubectl get cm | grep ext-provision-metadata | wc -l | xargs)
done

$CLI ext stop -v | sed 's/^/localdev │ /'

DOCKER_VOLUME_NAME=$(docker volume ls | grep dxp-data- | awk '{print $2}')

if [ "$DOCKER_VOLUME_NAME" == "" ]; then
	echo "Could not find expected docker volumn named 'dxp-data-*'"
	exit 1
else
	echo "Found docker volume named $DOCKER_VOLUME_NAME"
fi
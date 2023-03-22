#!/usr/bin/env bash

a="/$0"; a="${a%/*}"; a="${a:-.}"; a="${a##/}/"; BASEDIR=$(cd "$a"; pwd)
source ${BASEDIR}/_common.sh

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

startLocaldev

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

stopLocaldev

DOCKER_VOLUME_NAME=$(docker volume ls | grep dxp-data- | awk '{print $2}')

if [ "$DOCKER_VOLUME_NAME" == "" ]; then
	echo "Could not find expected docker volumn named 'dxp-data-*'"
	exit 1
else
	echo "Found docker volume named $DOCKER_VOLUME_NAME"
fi
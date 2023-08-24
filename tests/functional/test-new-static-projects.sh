#!/usr/bin/env bash

a="/$0"; a="${a%/*}"; a="${a:-.}"; a="${a##/}/"; BASEDIR=$(cd "$a"; pwd)
source ${BASEDIR}/_common.sh

$CLI ext create \
	-d ${WORKSPACE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/global-css" \
	--project-path="client-extensions/static/able-global-css" \
	--workspace-path="/workspace" \
	--args=id="able-global-css" \
	--args=name="Able Global CSS"

$CLI ext create \
	-d ${WORKSPACE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/global-js" \
	--project-path="client-extensions/static/bravo-global-js" \
	--workspace-path="/workspace" \
	--args=id="bravo-global-js" \
	--args=name="Bravo Global JS"

$CLI ext create \
	-d ${WORKSPACE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/remote-app-iframe" \
	--project-path="client-extensions/static/charlie-iframe" \
	--workspace-path="/workspace" \
	--args=id="charlie-iframe" \
	--args=name="Charlie iframe"

$CLI ext create \
	-d ${WORKSPACE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/remote-app-react" \
	--project-path="client-extensions/static/delta-remote-app" \
	--workspace-path="/workspace" \
	--args=id="delta-remote-app" \
	--args=name="Delta Remote App"

$CLI ext create \
	-d ${WORKSPACE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/remote-app-vanilla" \
	--project-path="client-extensions/static/echo-remote-app" \
	--workspace-path="/workspace" \
	--args=id="echo-remote-app" \
	--args=name="Echo Remote App"

$CLI ext create \
	-d ${WORKSPACE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/theme-css" \
	--project-path="client-extensions/static/fox-theme-css" \
	--workspace-path="/workspace" \
	--args=id="fox-theme-css" \
	--args=name="Fox Theme CSS"

$CLI ext create \
	-d ${WORKSPACE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/theme-favicon" \
	--project-path="client-extensions/static/golf-theme-favicon" \
	--workspace-path="/workspace" \
	--args=id="golf-theme-favicon" \
	--args=Name="Golf Theme Favicon"

startLocaldev

FOUND_LOCALDEV_SERVER=0
echo "     testcheck │ FOUND_LOCALDEV_SERVER"

until [ "$FOUND_LOCALDEV_SERVER" == "1" ]; do
	sleep 5
	FOUND_LOCALDEV_SERVER=$(docker ps | grep localdev-extension-runtime | wc -l)
done

FOUND_EXT_PROVISION_CONFIG_MAPS=0
echo "     testcheck │ FOUND_EXT_PROVISION_CONFIG_MAPS"

until [ "$FOUND_EXT_PROVISION_CONFIG_MAPS" == "7" ]; do
	sleep 5
	FOUND_EXT_PROVISION_CONFIG_MAPS=$(docker exec -i localdev-extension-runtime /entrypoint.sh kubectl get cm | grep ext-provision-metadata | wc -l | xargs)
done

DOCKER_VOLUME_NAME=$(docker volume ls | grep dxp-data- | awk '{print $2}')

if [ "$DOCKER_VOLUME_NAME" == "" ]; then
	echo "Could not find expected docker volumn named 'dxp-data-*'"
	exit 1
else
	echo "Found docker volume named $DOCKER_VOLUME_NAME"
fi
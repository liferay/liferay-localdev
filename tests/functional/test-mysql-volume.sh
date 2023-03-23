#!/usr/bin/env bash

a="/$0"; a="${a%/*}"; a="${a:-.}"; a="${a##/}/"; BASEDIR=$(cd "$a"; pwd)
source ${BASEDIR}/_common.sh

$CLI ext create \
	-d ${WORKSPACE_BASE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/global-css" \
	--workspace-path="test-global-css" \
	--args=id="test-global-css" \
	--args=name="Test Global CSS"

# copy the Tiltfile.mysql into workspace

cp ${LOCALDEV_REPO}/resources/tilt/Tiltfile.mysql ${WORKSPACE_BASE_PATH}/

startLocaldev

FOUND_LOCALDEV_SERVER=0
echo "     testcheck │ FOUND_LOCALDEV_SERVER"

until [ "$FOUND_LOCALDEV_SERVER" == "1" ]; do
	sleep 5
	FOUND_LOCALDEV_SERVER=$(docker ps | grep localdev-extension-runtime | wc -l)
done

FOUND_DB_SERVER=0
echo "     testcheck │ FOUND_DB_SERVER"

until [ "$FOUND_DB_SERVER" == "1" ]; do
	sleep 5
	FOUND_DB_SERVER=$(docker ps | grep mysql | wc -l)
done

FOUND_EXT_PROVISION_CONFIG_MAPS=0
echo "     testcheck │ FOUND_EXT_PROVISION_CONFIG_MAPS"

until [ "$FOUND_EXT_PROVISION_CONFIG_MAPS" == "1" ]; do
	sleep 5
	FOUND_EXT_PROVISION_CONFIG_MAPS=$(docker exec -i localdev-extension-runtime kubectl get cm | grep ext-provision-metadata | wc -l | xargs)
done

MYSQL_DOCKER_VOLUME_NAME=$(docker volume ls | grep mysqlData | awk '{print $2}')

if [ "$MYSQL_DOCKER_VOLUME_NAME" == "" ]; then
	echo "Could not find expected docker volume named 'mysqlData'"
	exit 1
else
	echo "Found docker volume named $MYSQL_DOCKER_VOLUME_NAME"
fi
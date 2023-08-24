#!/usr/bin/env bash

a="/$0"; a="${a%/*}"; a="${a:-.}"; a="${a##/}/"; BASEDIR=$(cd "$a"; pwd)
source ${BASEDIR}/_common.sh

$CLI ext create \
	-d ${WORKSPACE_PATH}/ \
	-v \
	--noprompt \
	-- \
	--project-path="client-extensions/test-global-css" \
	--resource-path="template/global-css" \
	--workspace-path="/workspace" \
	--args=id="test-global-css" \
	--args=name="Test Global CSS"

# copy the Tiltfile.mysql into workspace

cp ${LOCALDEV_REPO}/resources/tilt/Tiltfile.mysql ${WORKSPACE_PATH}/client-extensions/

startLocaldev

FOUND_LOCALDEV_SERVER=0
echo "     testcheck │ FOUND_LOCALDEV_SERVER"

until [ "$FOUND_LOCALDEV_SERVER" == "1" ]; do
	sleep 5
	FOUND_LOCALDEV_SERVER=$(docker ps | grep localdev-extension-runtime | wc -l)
done

echo "     testcheck │ FOUND_LOCALDEV_SERVER - PASSED"

FOUND_DB_SERVER=0
echo "     testcheck │ FOUND_DB_SERVER"

until [ "$FOUND_DB_SERVER" == "1" ]; do
	sleep 5
	FOUND_DB_SERVER=$(docker ps | grep mysql | wc -l)
done

echo "     testcheck │ FOUND_DB_SERVER - PASSED"

FOUND_EXT_PROVISION_CONFIG_MAPS=0
echo "     testcheck │ FOUND_EXT_PROVISION_CONFIG_MAPS"

until [ "$FOUND_EXT_PROVISION_CONFIG_MAPS" == "1" ]; do
	sleep 5
	FOUND_EXT_PROVISION_CONFIG_MAPS=$(docker exec -i localdev-extension-runtime kubectl get cm | grep ext-provision-metadata | wc -l | xargs)
done

echo "     testcheck │ FOUND_EXT_PROVISION_CONFIG_MAPS - PASSED"

MYSQL_DOCKER_VOLUME_NAME=$(docker volume ls | grep mysqlData | awk '{print $2}')
echo "     testcheck │ MYSQL_DOCKER_VOLUME_NAME"

if [ "$MYSQL_DOCKER_VOLUME_NAME" == "" ]; then
	echo "     testcheck │ MYSQL_DOCKER_VOLUME_NAME - FAILED"
	exit 1
else
	echo "     testcheck │ MYSQL_DOCKER_VOLUME_NAME - PASSED"
fi
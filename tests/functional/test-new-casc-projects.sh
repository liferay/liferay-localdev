#!/usr/bin/env bash

a="/$0"; a="${a%/*}"; a="${a:-.}"; a="${a##/}/"; BASEDIR=$(cd "$a"; pwd)
source ${BASEDIR}/_common.sh

$CLI ext create \
	-d ${WORKSPACE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/batch" \
	--project-path="client-extensions/casc/able-batch" \
	--workspace-path="${WORKSPACE_PATH}" \
	--args=id="able-batch" \
	--args=name="Able Batch"

startLocaldev

FOUND_LOCALDEV_SERVER=0
echo "     testcheck │ FOUND_LOCALDEV_SERVER"

until [ "$FOUND_LOCALDEV_SERVER" == "1" ]; do
	sleep 5
	FOUND_LOCALDEV_SERVER=$(docker ps | grep localdev-extension-runtime | wc -l)
done

echo "     testcheck │ FOUND_LOCALDEV_SERVER - PASSED"

FOUND_EXT_PROVISION_CONFIG_MAPS=0
echo "     testcheck │ FOUND_EXT_PROVISION_CONFIG_MAPS"

until [ "$FOUND_EXT_PROVISION_CONFIG_MAPS" == "1" ]; do
	sleep 5
	FOUND_EXT_PROVISION_CONFIG_MAPS=$(docker exec -i localdev-extension-runtime /entrypoint.sh kubectl get cm | grep ext-provision-metadata | wc -l | xargs)
done

echo "     testcheck │ FOUND_EXT_PROVISION_CONFIG_MAPS - PASSED"

FOUND_EXT_INIT_CONFIG_MAPS=0
echo "     testcheck │ FOUND_EXT_INIT_CONFIG_MAPS"

until [ "$FOUND_EXT_INIT_CONFIG_MAPS" == "1" ]; do
	sleep 5
	FOUND_EXT_INIT_CONFIG_MAPS=$(docker exec -i localdev-extension-runtime /entrypoint.sh kubectl get cm | grep ext-init-metadata | wc -l | xargs)
done

DOCKER_VOLUME_NAME=$(docker volume ls | grep dxp-data- | awk '{print $2}')

if [ "$DOCKER_VOLUME_NAME" == "" ]; then
	echo "Could not find expected docker volumn named 'dxp-data-*'"
	exit 1
else
	echo "Found docker volume named $DOCKER_VOLUME_NAME"
fi
#!/usr/bin/env bash

a="/$0"; a="${a%/*}"; a="${a:-.}"; a="${a##/}/"; BASEDIR=$(cd "$a"; pwd)
source ${BASEDIR}/_common.sh

$CLI ext create \
	-d ${WORKSPACE_BASE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/service-nodejs" \
	--workspace-path="service/able-nodejs-service" \
	--args=id="able-nodejs-service" \
	--args=name="Able Nodejs Service"

$CLI ext create \
	-d ${WORKSPACE_BASE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="partial/object-action-nodejs" \
	--workspace-path="service/able-nodejs-service" \
	--args=Object="Able" \
	--args=id="able-updated-nodejs" \
	--args=resourcePath="/able/updated"

$CLI ext create \
	-d ${WORKSPACE_BASE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/service-springboot" \
	--workspace-path="service/bravo-springboot-service" \
	--args=package="com.company.service"\
	--args=packagePath="com/company/service"

$CLI ext create \
	-d ${WORKSPACE_BASE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="partial/object-action-springboot" \
	--workspace-path="service/bravo-springboot-service" \
	--args=package="com.company.service" \
	--args=packagePath="com/company/service" \
	--args=Object="Bravo" \
	--args=id="bravo-updated-springboot" \
	--args=resourcePath="/bravo/updated"

$CLI ext create \
	-d ${WORKSPACE_BASE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/service-springboot" \
	--workspace-path="service/charlie-springboot-service" \
	--args=package="com.company.service" \
	--args=packagePath="com/company/service"

$CLI ext create \
	-d ${WORKSPACE_BASE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="partial/workflow-action-springboot" \
	--workspace-path="service/charlie-springboot-service" \
	--args=id="my-workflow-action" \
	--args=actionName="MyWorkflowAction" \
	--args=package="com.company.service" \
	--args=packagePath="com/company/service" \
	--args=resourcePath="/workflow/action"

$CLI ext create \
	-d ${WORKSPACE_BASE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/service-springboot" \
	--workspace-path="service/delta-springboot-service" \
	--args=package="com.company.service" \
	--args=packagePath="com/company/service"

$CLI ext create \
	-d ${WORKSPACE_BASE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="partial/notification-type-springboot" \
	--workspace-path="service/delta-springboot-service" \
	--args=id="my-notification-type" \
	--args=notificationTypeName="MyNotificationType" \
	--args=package="com.company.service" \
	--args=packagePath="com/company/service" \
	--args=resourcePath="/mynotificationtype/send"

startLocaldev

FOUND_LOCALDEV_SERVER=0
echo "testcheck │ FOUND_LOCALDEV_SERVER"

until [ "$FOUND_LOCALDEV_SERVER" == "1" ]; do
	sleep 5
	FOUND_LOCALDEV_SERVER=$(docker ps | grep localdev-extension-runtime | wc -l)
done

FOUND_EXT_PROVISION_CONFIG_MAPS=0
echo "testcheck │ FOUND_EXT_PROVISION_CONFIG_MAPS"

until [ "$FOUND_EXT_PROVISION_CONFIG_MAPS" == "4" ]; do
	sleep 5
	FOUND_EXT_PROVISION_CONFIG_MAPS=$(docker exec -i localdev-extension-runtime /entrypoint.sh kubectl get cm | grep ext-provision-metadata | wc -l | xargs)
done

FOUND_EXT_INIT_CONFIG_MAPS=0
echo "testcheck │ FOUND_EXT_INIT_CONFIG_MAPS"

until [ "$FOUND_EXT_INIT_CONFIG_MAPS" == "4" ]; do
	sleep 5
	FOUND_EXT_INIT_CONFIG_MAPS=$(docker exec -i localdev-extension-runtime /entrypoint.sh kubectl get cm | grep ext-init-metadata | wc -l | xargs)
done

stopLocaldev

DOCKER_VOLUME_NAME=$(docker volume ls | grep dxp-data- | awk '{print $2}')

if [ "$DOCKER_VOLUME_NAME" == "" ]; then
	echo "Could not find expected docker volumn named 'dxp-data-*'"
	exit 1
else
	echo "Found docker volume named $DOCKER_VOLUME_NAME"
fi
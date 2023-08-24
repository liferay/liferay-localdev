#!/usr/bin/env bash

a="/$0"; a="${a%/*}"; a="${a:-.}"; a="${a##/}/"; BASEDIR=$(cd "$a"; pwd)
source ${BASEDIR}/_common.sh

$CLI ext create \
	-d ${WORKSPACE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/service-nodejs" \
	--project-path="client-extensions/service/able-nodejs-service" \
	--workspace-path="${WORKSPACE_PATH}" \
	--args=id="able-nodejs-service" \
	--args=name="Able Nodejs Service"

$CLI ext create \
	-d ${WORKSPACE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="partial/object-action-nodejs" \
	--project-path="client-extensions/service/able-nodejs-service" \
	--workspace-path="${WORKSPACE_PATH}" \
	--args=Object="Able" \
	--args=id="able-updated-nodejs" \
	--args=resourcePath="/able/updated"

$CLI ext create \
	-d ${WORKSPACE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/service-springboot" \
	--project-path="client-extensions/service/bravo-springboot-service" \
	--workspace-path="${WORKSPACE_PATH}" \
	--args=package="com.company.service"\
	--args=packagePath="com/company/service"

$CLI ext create \
	-d ${WORKSPACE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="partial/object-action-springboot" \
	--project-path="client-extensions/service/bravo-springboot-service" \
	--workspace-path="${WORKSPACE_PATH}" \
	--args=package="com.company.service" \
	--args=packagePath="com/company/service" \
	--args=Object="Bravo" \
	--args=id="bravo-updated-springboot" \
	--args=resourcePath="/bravo/updated"

$CLI ext create \
	-d ${WORKSPACE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/service-springboot" \
	--project-path="client-extensions/service/charlie-springboot-service" \
	--workspace-path="${WORKSPACE_PATH}" \
	--args=package="com.company.service" \
	--args=packagePath="com/company/service"

$CLI ext create \
	-d ${WORKSPACE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="partial/workflow-action-springboot" \
	--project-path="client-extensions/service/charlie-springboot-service" \
	--workspace-path="${WORKSPACE_PATH}" \
	--args=id="my-workflow-action" \
	--args=actionName="MyWorkflowAction" \
	--args=package="com.company.service" \
	--args=packagePath="com/company/service" \
	--args=resourcePath="/workflow/action"

$CLI ext create \
	-d ${WORKSPACE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/service-springboot" \
	--project-path="client-extensions/service/delta-springboot-service" \
	--workspace-path="${WORKSPACE_PATH}" \
	--args=package="com.company.service" \
	--args=packagePath="com/company/service"

$CLI ext create \
	-d ${WORKSPACE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="partial/notification-type-springboot" \
	--project-path="client-extensions/service/delta-springboot-service" \
	--workspace-path="${WORKSPACE_PATH}" \
	--args=id="my-notification-type" \
	--args=notificationTypeName="MyNotificationType" \
	--args=package="com.company.service" \
	--args=packagePath="com/company/service" \
	--args=resourcePath="/mynotificationtype/send"

startLocaldev

FOUND_LOCALDEV_SERVER=0
echo "     testcheck │ FOUND_LOCALDEV_SERVER"

until [ "$FOUND_LOCALDEV_SERVER" == "1" ]; do
	sleep 5
	FOUND_LOCALDEV_SERVER=$(docker ps | grep localdev-extension-runtime | wc -l)
done

FOUND_EXT_PROVISION_CONFIG_MAPS=0
echo "     testcheck │ FOUND_EXT_PROVISION_CONFIG_MAPS"

until [ "$FOUND_EXT_PROVISION_CONFIG_MAPS" == "4" ]; do
	sleep 5
	FOUND_EXT_PROVISION_CONFIG_MAPS=$(docker exec -i localdev-extension-runtime /entrypoint.sh kubectl get cm | grep ext-provision-metadata | wc -l | xargs)
done

FOUND_EXT_INIT_CONFIG_MAPS=0
echo "     testcheck │ FOUND_EXT_INIT_CONFIG_MAPS"

until [ "$FOUND_EXT_INIT_CONFIG_MAPS" == "4" ]; do
	sleep 5
	FOUND_EXT_INIT_CONFIG_MAPS=$(docker exec -i localdev-extension-runtime /entrypoint.sh kubectl get cm | grep ext-init-metadata | wc -l | xargs)
done

DOCKER_VOLUME_NAME=$(docker volume ls | grep dxp-data- | awk '{print $2}')
echo "     testcheck │ DOCKER_VOLUME_NAME"

if [ "$DOCKER_VOLUME_NAME" == "" ]; then
	echo "     testcheck │ DOCKER_VOLUME_NAME - FAILED"
	exit 1
else
	echo "     testcheck │ DOCKER_VOLUME_NAME - PASSED"
fi
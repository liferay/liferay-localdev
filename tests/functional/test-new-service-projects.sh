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

$CLI ext start -v -d ${WORKSPACE_BASE_PATH} &

FOUND_LOCALDEV_SERVER=0

until [ "$FOUND_LOCALDEV_SERVER" == "1" ]; do
	sleep 5
	FOUND_LOCALDEV_SERVER=$(docker ps | grep localdev-extension-runtime | wc -l)
	echo "FOUND_LOCALDEV_SERVER=${FOUND_LOCALDEV_SERVER}"
done

FOUND_EXT_PROVISION_CONFIG_MAPS=0

until [ "$FOUND_EXT_PROVISION_CONFIG_MAPS" == "4" ]; do
	sleep 60
	FOUND_EXT_PROVISION_CONFIG_MAPS=$(docker exec -i localdev-extension-runtime /entrypoint.sh kubectl get cm | grep ext-provision-metadata | wc -l | xargs)
	echo "FOUND_EXT_PROVISION_CONFIG_MAPS=${FOUND_EXT_PROVISION_CONFIG_MAPS}"
	docker logs -n 50 localdev-extension-runtime
done

FOUND_EXT_INIT_CONFIG_MAPS=0

until [ "$FOUND_EXT_INIT_CONFIG_MAPS" == "4" ]; do
	sleep 60
	FOUND_EXT_INIT_CONFIG_MAPS=$(docker exec -i localdev-extension-runtime /entrypoint.sh kubectl get cm | grep ext-init-metadata | wc -l | xargs)
	echo "FOUND_EXT_INIT_CONFIG_MAPS=${FOUND_EXT_INIT_CONFIG_MAPS}"
	docker logs -n 50 localdev-extension-runtime
done

$CLI ext stop -v

DOCKER_VOLUME_NAME=$(docker volume ls | grep dxp-data- | awk '{print $2}')

if [ "$DOCKER_VOLUME_NAME" == "" ]; then
	echo "Could not find expected docker volumn named 'dxp-data-*'"
	exit 1
else
	echo "Found docker volume named $DOCKER_VOLUME_NAME"
fi
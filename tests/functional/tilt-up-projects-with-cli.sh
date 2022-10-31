#!/usr/bin/env bash

set -e

LIFERAY_CLI_BRANCH="main"

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
	-v \
	--noprompt \
	-- \
	--resource-path="template/configuration" \
	--workspace-path="coupon-configuration" \
	--args=id="coupon-configuration-import" \
	--args=name="Coupon Configuration Import"

$CLI ext create \
	-v \
	--noprompt \
	-- \
	--resource-path="template/service-springboot" \
	--workspace-path="coupon-service-springboot" \
	--args=package="com.company.service"\
	--args=packagePath="com/company/service"

$CLI ext create \
	-v \
	--noprompt \
	-- \
	--resource-path="partial/object-action-springboot" \
	--workspace-path="coupon-service-springboot" \
	--args=package="com.company.service" \
	--args=packagePath="com/company/service" \
	--args=Object="Coupon" \
	--args=id=coupon \
	--args=resourcePath="/coupon/updated"

$CLI ext create \
	-v \
	--noprompt \
	-- \
	--resource-path="template/service-nodejs" \
	--workspace-path="coupon-service-nodejs" \
	--args=id="coupon-service-nodejs"

$CLI ext create \
	-v \
	--noprompt \
	-- \
	--resource-path="partial/object-action-nodejs" \
	--workspace-path="coupon-service-nodejs" \
	--args=Object="Coupon" \
	--args=id=coupon \
	--args=resourcePath="/coupon/updated"

$CLI ext start -d ${WORKSPACE_BASE_PATH}

FOUND_LOCALDEV_SERVER=0

until [ "$FOUND_LOCALDEV_SERVER" == "1" ]; do
	sleep 5
	FOUND_LOCALDEV_SERVER=$(docker ps | grep localdev-extension-runtime | wc -l)
	echo "FOUND_LOCALDEV_SERVER=${FOUND_LOCALDEV_SERVER}"
done

FOUND_EXT_PROVISION_CONFIG_MAPS=0

until [ "$FOUND_EXT_PROVISION_CONFIG_MAPS" == "3" ]; do
	sleep 5
	FOUND_EXT_PROVISION_CONFIG_MAPS=$(docker exec -i localdev-extension-runtime /entrypoint.sh kubectl get cm | grep ext-provision-metadata | wc -l | xargs)
	echo "FOUND_EXT_PROVISION_CONFIG_MAPS=${FOUND_EXT_PROVISION_CONFIG_MAPS}"
	docker logs -n 50 localdev-extension-runtime
done

FOUND_EXT_INIT_CONFIG_MAPS=0

until [ "$FOUND_EXT_INIT_CONFIG_MAPS" == "3" ]; do
	sleep 5
	FOUND_EXT_INIT_CONFIG_MAPS=$(docker exec -i localdev-extension-runtime /entrypoint.sh kubectl get cm | grep ext-init-metadata | wc -l | xargs)
	echo "FOUND_EXT_INIT_CONFIG_MAPS=${FOUND_EXT_INIT_CONFIG_MAPS}"
	docker logs -n 50 localdev-extension-runtime
done

$CLI runtime delete
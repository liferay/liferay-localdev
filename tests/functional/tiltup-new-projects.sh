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
	--resource-path="template/configuration" \
	--workspace-path="casc/able-configuration" \
	--args=id="able-configuration" \
	--args=name="Able Configuration"

$CLI ext create \
	-d ${WORKSPACE_BASE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/global-css" \
	--workspace-path="static/bravo-global-css" \
	--args=id="bravo-global-css" \
	--args=name="Bravo Global CSS"

$CLI ext create \
	-d ${WORKSPACE_BASE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/global-js" \
	--workspace-path="static/charlie-global-js" \
	--args=id="charlie-global-js" \
	--args=name="Charlie Global JS"

$CLI ext create \
	-d ${WORKSPACE_BASE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/remote-app-iframe" \
	--workspace-path="static/delta-iframe" \
	--args=id="delta-iframe" \
	--args=name="Debra iframe"

$CLI ext create \
	-d ${WORKSPACE_BASE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/remote-app-react" \
	--workspace-path="static/echo-remote-app" \
	--args=id="echo-remote-app" \
	--args=name="Echo Remote App"

$CLI ext create \
	-d ${WORKSPACE_BASE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/remote-app-vanilla" \
	--workspace-path="static/fox-remote-app" \
	--args=id="fox-remote-app" \
	--args=name="Fox Remote App"

$CLI ext create \
	-d ${WORKSPACE_BASE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/service-nodejs" \
	--workspace-path="service/golf-nodejs-service" \
	--args=id="golf-nodejs-service" \
	--args=name="Golf Nodejs Service"

$CLI ext create \
	-d ${WORKSPACE_BASE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="partial/object-action-nodejs" \
	--workspace-path="service/golf-nodejs-service" \
	--args=Object="Coupon" \
	--args=id="coupon-updated-nodejs" \
	--args=resourcePath="/coupon/updated"

$CLI ext create \
	-d ${WORKSPACE_BASE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/service-springboot" \
	--workspace-path="service/hotel-springboot-service" \
	--args=package="com.company.service"\
	--args=packagePath="com/company/service"

$CLI ext create \
	-d ${WORKSPACE_BASE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="partial/object-action-springboot" \
	--workspace-path="service/hotel-springboot-service" \
	--args=package="com.company.service" \
	--args=packagePath="com/company/service" \
	--args=Object="Coupon" \
	--args=id="coupon-updated-springboot" \
	--args=resourcePath="/coupon/updated"

$CLI ext create \
	-d ${WORKSPACE_BASE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/theme-css" \
	--workspace-path="static/india-theme-css" \
	--args=id="india-theme-css" \
	--args=name="India Theme CSS"

$CLI ext create \
	-d ${WORKSPACE_BASE_PATH} \
	-v \
	--noprompt \
	-- \
	--resource-path="template/theme-favicon" \
	--workspace-path="static/juliet-theme-favicon" \
	--args=id="juliet-theme-favicon"\
	--args=Name="Juliet Theme Favicon"

$CLI ext start -v -d ${WORKSPACE_BASE_PATH} &

FOUND_LOCALDEV_SERVER=0

until [ "$FOUND_LOCALDEV_SERVER" == "1" ]; do
	sleep 5
	FOUND_LOCALDEV_SERVER=$(docker ps | grep localdev-extension-runtime | wc -l)
	echo "FOUND_LOCALDEV_SERVER=${FOUND_LOCALDEV_SERVER}"
done

FOUND_EXT_PROVISION_CONFIG_MAPS=0

until [ "$FOUND_EXT_PROVISION_CONFIG_MAPS" == "10" ]; do
	sleep 60
	FOUND_EXT_PROVISION_CONFIG_MAPS=$(docker exec -i localdev-extension-runtime /entrypoint.sh kubectl get cm | grep ext-provision-metadata | wc -l | xargs)
	echo "FOUND_EXT_PROVISION_CONFIG_MAPS=${FOUND_EXT_PROVISION_CONFIG_MAPS}"
	docker logs -n 50 localdev-extension-runtime
done

FOUND_EXT_INIT_CONFIG_MAPS=0

until [ "$FOUND_EXT_INIT_CONFIG_MAPS" == "3" ]; do
	sleep 60
	FOUND_EXT_INIT_CONFIG_MAPS=$(docker exec -i localdev-extension-runtime /entrypoint.sh kubectl get cm | grep ext-init-metadata | wc -l | xargs)
	echo "FOUND_EXT_INIT_CONFIG_MAPS=${FOUND_EXT_INIT_CONFIG_MAPS}"
	docker logs -n 50 localdev-extension-runtime
done

$CLI ext stop -v

$CLI runtime delete -v
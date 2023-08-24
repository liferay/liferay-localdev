#!/usr/bin/env bash

set -e

LOCALDEV_REPO=${LOCALDEV_REPO:--../}
export RESOURCES_BASE_PATH="${LOCALDEV_REPO}/resources/"
export WORKSPACE_PATH="${LOCALDEV_REPO}/resources/sample/coupon-with-object-actions"
BUILD_CMD=${LOCALDEV_REPO}/scripts/ext/build.sh
CREATE_CMD=${LOCALDEV_REPO}/scripts/ext/create.py
BUILD_PROJECTS=${BUILD_PROJECTS:-true}

rm -rf $WORKSPACE_PATH && mkdir -p $WORKSPACE_PATH

cp -R "${LOCALDEV_REPO}"/tests/workspace/* "${WORKSPACE_PATH}"

# Warning, these CREATE_ARGS are whitespace sensitive!

CREATE_ARGS="\
--project-path=client-extensions/coupon-batch|\
--resource-path=template/batch|\
--workspace-path=${WORKSPACE_PATH}|\
--args=id=coupon-batch|\
--args=name=Coupon Batch" $CREATE_CMD

CREATE_ARGS="\
--project-path=client-extensions/coupon-service-nodejs|\
--resource-path=template/service-nodejs|\
--workspace-path=${WORKSPACE_PATH}|\
--args=id=coupon-service-nodejs" $CREATE_CMD

CREATE_ARGS="\
--project-path=client-extensions/coupon-service-springboot|\
--resource-path=template/service-springboot|\
--workspace-path=${WORKSPACE_PATH}|\
--args=package=com.company.service|\
--args=packagePath=com/company/service" $CREATE_CMD

CREATE_ARGS="\
--resource-path=partial/object-action-nodejs|\
--project-path=client-extensions/coupon-service-nodejs|\
--workspace-path=${WORKSPACE_PATH}|\
--args=id=coupon-updated-nodejs|\
--args=name=Coupon Updated (Nodejs)|\
--args=Object=Coupon|\
--args=resourcePath=/coupon/updated" $CREATE_CMD

CREATE_ARGS="\
--project-path=client-extensions/coupon-service-springboot|\
--resource-path=partial/object-action-springboot|\
--workspace-path=${WORKSPACE_PATH}|\
--args=id=coupon-updated-springboot|\
--args=name=Coupon Updated (Springboot)|\
--args=Object=Coupon|\
--args=package=com.company.service|\
--args=packagePath=com/company/service|\
--args=resourcePath=/coupon/updated" $CREATE_CMD
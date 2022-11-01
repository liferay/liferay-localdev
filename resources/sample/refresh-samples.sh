#!/usr/bin/env bash

set -e

export RESOURCES_BASE_PATH="${LOCALDEV_REPO}/resources/"
export WORKSPACE_BASE_PATH="${LOCALDEV_REPO}/resources/sample/coupon-with-object-actions"
BUILD_CMD=${LOCALDEV_REPO}/scripts/ext/build.sh
CREATE_CMD=${LOCALDEV_REPO}/scripts/ext/create.py
BUILD_PROJECTS=${BUILD_PROJECTS:-true}

rm -rf $WORKSPACE_BASE_PATH && mkdir -p $WORKSPACE_BASE_PATH

# Warning, these CREATE_ARGS are whitespace sensitive!

CREATE_ARGS="\
--workspace-path=coupon-configuration|\
--resource-path=template/configuration|\
--args=id=coupon-configuration|\
--args=name=Coupon Configuration as Code" $CREATE_CMD

CREATE_ARGS="\
--workspace-path=coupon-service-nodejs|\
--resource-path=template/service-nodejs|\
--args=id=coupon-service-nodejs" $CREATE_CMD

CREATE_ARGS="\
--workspace-path=coupon-service-springboot|\
--resource-path=template/service-springboot|\
--args=package=com.company.service|\
--args=packagePath=com/company/service" $CREATE_CMD

CREATE_ARGS="\
--workspace-path=coupon-service-nodejs|\
--resource-path=partial/object-action-nodejs|\
--args=id=coupon-updated-nodejs|\
--args=name=Coupon Updated (Nodejs)|\
--args=resourcePath=/coupon/updated" $CREATE_CMD

CREATE_ARGS="\
--workspace-path=coupon-service-springboot|\
--resource-path=partial/object-action-springboot|\
--args=id=coupon-updated-springboot|\
--args=name=Coupon Updated (Springboot)|\
--args=Object=Coupon|\
--args=package=com.company.service|\
--args=packagePath=com/company/service|\
--args=resourcePath=/coupon/updated" $CREATE_CMD
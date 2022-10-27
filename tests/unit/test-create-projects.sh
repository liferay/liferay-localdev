#!/usr/bin/env bash

set -e

export PROJECTS_BASE_PATH="${LOCALDEV_REPO}/tests/work/"
export RESOURCES_BASE_PATH="${LOCALDEV_REPO}/resources/"
CREATE_CMD=${LOCALDEV_REPO}/scripts/ext/create.py

rm -rf $PROJECTS_BASE_PATH && mkdir -p $PROJECTS_BASE_PATH

$CREATE_CMD \
  --workspace-path=solution-a/able-global-css \
  --resource-path=template/global-css \
  name=foo 

$CREATE_CMD \
  --project-path=foo-theme-css \
  --template-path=theme-css \
  id=foo \
  name="Foo Theme CSS"

$CREATE_CMD \
  --project-path=foo-configuration \
  --template-path=configuration \
  id=foo \
  name="Foo Configuration"

$CREATE_CMD \
  --project-path=foo-springboot-service \
  --template-path=service-springboot \
  id=foo \
  name="Foo Service" \
  package=com.liferay.test \
  packagePath="com/liferay/test"

$CREATE_CMD \
  --project-path=foo-nodejs-service \
  --template-path=service-nodejs \
  id=foo \
  name="Foo Service"
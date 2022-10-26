#!/usr/bin/env bash

set -e

export PROJECTS_BASE_PATH="${LOCALDEV_REPO}/tests/work/"
export TEMPLATES_BASE_PATH="${LOCALDEV_REPO}/templates/projects/"
CREATE_CMD=${LOCALDEV_REPO}/scripts/ext/create.py

rm -rf $PROJECTS_BASE_PATH && mkdir -p $PROJECTS_BASE_PATH

$CREATE_CMD \
  --project-path=foo-configuration \
  --template-path=configuration \
  id=foo \
  name=bar

$CREATE_CMD \
  --project-path=bar-service \
  --template-path=service-springboot \
  id=foo \
  name=bar \
  package=com.liferay.test \
  packagePath="com/liferay/test"
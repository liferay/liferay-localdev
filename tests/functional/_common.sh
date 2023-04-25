#!/bin/bash

a="/$0"; a="${a%/*}"; a="${a:-.}"; a="${a##/}/"; BASEDIR=$(cd "$a"; pwd)

if [ "${LOCALDEV_REPO}" == "x" ]; then
	LOCALDEV_REPO=$(realpath ${BASEDIR}/../..)
	echo "LOCALDEV_REPO=${LOCALDEV_REPO}"
fi

set -e

trap stopLocaldev EXIT

LIFERAY_CLI_BRANCH="${LIFERAY_CLI_BRANCH:-next}"
LIFERAY_CLI_REMOTE="${LIFERAY_CLI_REMOTE:-https://github.com/liferay/liferay-cli}"

if [ "$LIFERAY_CLI_BRANCH" != "" ]; then
	if [ $(git -C ${LOCALDEV_REPO}/tests/work/liferay rev-parse --is-inside-work-tree 2> /dev/null) ]; then
		git \
			-C ${LOCALDEV_REPO}/tests/work/liferay \
			pull \
			--depth 1 \
			${LIFERAY_CLI_REMOTE} \
			$LIFERAY_CLI_BRANCH
	else
		git clone \
			--branch $LIFERAY_CLI_BRANCH \
			--depth 1 \
			${LIFERAY_CLI_REMOTE} \
			${LOCALDEV_REPO}/tests/work/liferay
	fi

	cd ${LOCALDEV_REPO}/tests/work/liferay

	CLI="./gow run main.go"
else
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/liferay/liferay-cli/HEAD/install.sh)"

	CLI="liferay"
fi

if [ -e ${LOCALDEV_REPO}/tests/work/workspace ]; then
	rm -rf ${LOCALDEV_REPO}/tests/work/workspace
fi

$CLI config set localdev.resources.dir ${LOCALDEV_REPO}

$CLI config set localdev.resources.sync false

$CLI runtime mkcert

$CLI runtime mkcert --install

BASE_PATH=${LOCALDEV_REPO}/tests/work/workspace/client-extensions

mkdir -p $BASE_PATH

export CLI
export WORKSPACE_BASE_PATH="$BASE_PATH"
export BUILD_PROJECTS="false"

startLocaldev() {
	($CLI ext start -v -d ${WORKSPACE_BASE_PATH} | sed 's/^/localdev start │ /') &
}

stopLocaldev() {
	($CLI rt delete -v | sed 's/^/ localdev stop │ /')

	for i in $(docker volume ls -q --filter dangling=true); do
		docker volume rm $i | sed 's/^/ localdev stop │ /'
	done
}
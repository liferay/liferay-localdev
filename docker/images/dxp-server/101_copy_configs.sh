#!/bin/bash

function copy_configs {
	CONFIGS_DIR="/home/liferay/configs/${LIFERAY_WORKSPACE_ENVIRONMENT}"

	if [ -n "$(ls -A ${CONFIGS_DIR}/* 2> /dev/null)" ]; then
		echo "[LIFERAY] Copying ${CONFIGS_DIR} config files:"
		echo ""

		tree --noreport "${CONFIGS_DIR}"

		echo ""
		echo "Processing configs..."

		find "${CONFIGS_DIR}" -type f -print0 | xargs sed -i "s/__LFRDEV_DOMAIN__/${LFRDEV_DOMAIN}/g"
		for i in $(find "${CONFIGS_DIR}" -type f -print | grep __LFRDEV_DOMAIN__); do
			mv $i $(echo $i | sed "s/__LFRDEV_DOMAIN__/${LFRDEV_DOMAIN}/g")
		done

		echo ""
		echo "[LIFERAY] ... into ${LIFERAY_HOME}."

		cp -R "${CONFIGS_DIR}"/* ${LIFERAY_HOME}

		echo ""
	fi
}

function main {
	copy_configs
}

main
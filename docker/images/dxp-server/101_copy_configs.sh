#!/bin/bash

function copy_configs {
	CONFIGS_DIR="/home/liferay/configs/${LIFERAY_WORKSPACE_ENVIRONMENT}"

	if [ -n "$(ls -A ${CONFIGS_DIR}/* 2> /dev/null)" ]; then
		echo "[LIFERAY] Copying ${CONFIGS_DIR} config files:"
		echo ""

		tree --noreport "${CONFIGS_DIR}"

		echo ""
		echo "Processing configs..."

		for file in $(find "${CONFIGS_DIR}" -type f -print); do
			sed -i "s/__LFRDEV_DOMAIN__/${LFRDEV_DOMAIN}/g" $file
		done
		for file in $(find "${CONFIGS_DIR}" -type f -print | grep __LFRDEV_DOMAIN__); do
			mv $file $(echo $file | sed "s/__LFRDEV_DOMAIN__/${LFRDEV_DOMAIN}/g")
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
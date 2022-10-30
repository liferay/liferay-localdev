#!/bin/bash

set -e

# CURL_FLAGS        sets the curl commands to verbose mode
# OAUTH2_JOB_PROFILE  sets the oauth profile to use

CA_CERT="../rootCA.pem"

JOB_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "########################"
echo "JOB DIR = $JOB_DIR"

echo "########################"
DATA_FILES=$(find . -type f -name *.data.batch-engine.json)

if [ "${DATA_FILES}" == "" ]; then
	echo "There are no data files. Exiting with nothing to do!"
	exit 0
fi

echo "########################"
if [ "$OAUTH2_JOB_PROFILE" == "" ];then
	cat <<EOF
No OAuth Profile was selected for JOB processing!

Please set the environment variable OAUTH2_JOB_PROFILE in your
client-extension.yaml.

e.g.

runtime:
  type: configuration
  env:
  - name: OAUTH2_JOB_PROFILE
    value: "foo-oauth-application-headless-server"


EOF
	exit 1
else
	echo "OAUTH2_JOB_PROFILE = ${OAUTH2_JOB_PROFILE}"
fi

echo "########################"
echo "Mounted Config:"
find /etc/liferay/lxc/ext-init-metadata -type l -not -ipath "*/..data" -print -exec sed 's/^/    /' {} \; -exec echo "" \;
find /etc/liferay/lxc/dxp-metadata -type l -not -ipath "*/..data" -print -exec sed 's/^/    /' {} \; -exec echo "" \;

echo "########################"
DXP_HOST=$(cat /etc/liferay/lxc/dxp-metadata/com.liferay.lxc.dxp.mainDomain)
OAUTH2_CLIENTID=$(cat /etc/liferay/lxc/ext-init-metadata/${OAUTH2_JOB_PROFILE}.oauth2.headless.server.client.id)
OAUTH2_SECRET=$(cat /etc/liferay/lxc/ext-init-metadata/${OAUTH2_JOB_PROFILE}.oauth2.headless.server.client.secret)

echo "DXP_HOST: ${DXP_HOST}"
echo "OAUTH2_JOB_PROFILE: ${OAUTH2_JOB_PROFILE}"
echo "OAUTH2_CLIENTID: ${OAUTH2_CLIENTID}"
echo "OAUTH2_SECRET: ${OAUTH2_SECRET}"

echo "########################"
TOKEN_RESULT=$(\
	curl \
		-s \
		$CURL_FLAGS \
		-X POST \
		"https://${DXP_HOST}/o/oauth2/token" \
		-H 'Content-type: application/x-www-form-urlencoded' \
		-d "grant_type=client_credentials&client_id=${OAUTH2_CLIENTID}&client_secret=${OAUTH2_SECRET}" \
		--cacert ${CA_CERT} \
		| jq -r '.')

echo "TOKEN_RESULT: ${TOKEN_RESULT}"

ACCESS_TOKEN=$(jq -r '.access_token' <<< $TOKEN_RESULT)

echo "ACCESS_TOKEN: ${ACCESS_TOKEN}"

if [ "${ACCESS_TOKEN}" == "null" ];then
	exit 1
fi

process_batch() {
	echo "########################"
	echo "######### BATCH ${1}"

	local BATCH_ITEMS=$(jq -r '.items' ${1})

	ITEM_IDS=$(jq -r '[.[] | .id] | join(" ")' <<< $BATCH_ITEMS)

	# TODO: The URL '.actions.batch.href' should actually be available on any
	# resources that support batch and we should be able to fetch it without
	# manipulation aside from stripping the protocol and domain.
	local BASE_HREF=$(jq -r '.actions.create.href' ${1})
	BASE_HREF="/${BASE_HREF#*://*/}"
	echo "BASE_HREF=${BASE_HREF}"

	local BATCH_HREF=$(jq -r '.actions.createBatch.href' ${1})
	BATCH_HREF="/${BATCH_HREF#*://*/}"
	echo "BATCH_HREF=${BATCH_HREF}"

	local PARAMETERS=$(jq -r '[map_values(. | @uri) | to_entries[] | .key + "=" + .value] | join("&")' ${1}.parameters 2>/dev/null)
	echo "PARAMETERS=${PARAMETERS}"

	if [ "$PARAMETERS" != "" ]; then
		PARAMETERS="?${PARAMETERS}"
	else
		PARAMETERS="?createStrategy=UPSERT"
	fi

	local RESULT=$(\
		curl \
			-s \
			$CURL_FLAGS \
			-X 'POST' \
			"https://${DXP_HOST}${BATCH_HREF}${PARAMETERS}" \
			-H 'accept: application/json' \
			-H 'Content-Type: application/json' \
			-H "Authorization: Bearer ${ACCESS_TOKEN}" \
			-d "${BATCH_ITEMS}" \
			--cacert ${CA_CERT} \
			| jq -r '.')

	if [ "${RESULT}x" == "x" ]; then
		echo "An error occured"
		exit 1
	fi

	echo "RESULT=${RESULT}"

	local BATCH_EXTERNAL_REFERENCE_CODE=$(jq -r '.externalReferenceCode' <<< "$RESULT")

	local BATCH_STATUS="INITIAL"

	until [ "${BATCH_STATUS}" == "COMPLETED" ] || [ "${BATCH_STATUS}" == "FAILED" ] || [ "${BATCH_STATUS}" == "NOT_FOUND" ]; do
		RESULT=$(\
			curl \
				-s \
				$CURL_FLAGS \
				-X 'GET' \
				"https://${DXP_HOST}/o/headless-batch-engine/v1.0/import-task/by-external-reference-code/${BATCH_EXTERNAL_REFERENCE_CODE}" \
				-H 'accept: application/json' \
				-H "Authorization: Bearer ${ACCESS_TOKEN}" \
				--cacert ${CA_CERT} \
				| jq -r '.')

		BATCH_STATUS=$(jq -r '.executeStatus//.status' <<< "$RESULT")

		echo "BATCH STATUS: ${BATCH_STATUS}"
	done

	if [ "${BATCH_STATUS}" == "COMPLETED" ] || [ "${BATCH_STATUS}" == "FAILED" ] ; then
		local BATCH_EXTERNAL_REFERENCE_CODES=$(jq -r '[.items[].externalReferenceCode] | join(" ")' ${1})

		for i in $BATCH_EXTERNAL_REFERENCE_CODES; do
			ENTRY=$(
				curl \
					-s \
					$CURL_FLAGS \
					"https://${DXP_HOST}${BASE_HREF}/by-external-reference-code/${i}" \
					-H 'accept: application/json' \
					-H "Authorization: Bearer ${ACCESS_TOKEN}" \
					--cacert ${CA_CERT} \
					| jq -r .)

			STATUS=$(jq -r '.status.code' <<< $ENTRY)
			STATUS_LABEL_I18N=$(jq -r '.status.label_i18n' <<< $ENTRY)

			echo "Status of ${i} : ${STATUS_LABEL_I18N}"

			if [ $STATUS -eq 2 ];then
				ENTRY_ID=$(jq -r '.id' <<< $ENTRY)

				PUBLISHED=$(
					curl \
						-s \
						$CURL_FLAGS \
						-X 'POST' \
						"https://${DXP_HOST}${BASE_HREF}/${ENTRY_ID}/publish" \
						-H 'accept: application/json' \
						-H "Authorization: Bearer ${ACCESS_TOKEN}" \
						--cacert ../ca.crt \
						| jq -r .)

				echo "PUBLISHED: ${ENTRY_ID}"
			fi
		done
	fi
}

for i in $DATA_FILES; do
	process_batch $i
done

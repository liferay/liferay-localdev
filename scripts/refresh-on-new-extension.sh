#!/bin/bash

REPO="${LOCALDEV_REPO:-/repo}"

CLIENT_EXTENSION_YAML="client-extension.yaml"
REFRESH_CMD="${REPO}/scripts/ext/exec/refresh.sh &>/dev/null"

inotifywait -q -m -r -e CREATE -e MOVED_TO -e MOVE_SELF $1 | while read DIRECTORY EVENT FILE; do
	#echo "INOTIFY: $DIRECTORY | $EVENT | $FILE"
	case "$EVENT" in
			(CREATE)
			if [ "$FILE" == "$CLIENT_EXTENSION_YAML" ]; then
				case "$DIRECTORY" in
						(*\/build\/*)
						;;
						(*\/node_modules\/*)
						;;
						(*)
						$REFRESH_CMD
						;;
				esac
			fi
			;;
			(MOVED_TO,ISDIR)
			if [ -e "${DIRECTORY}${FILE}/$CLIENT_EXTENSION_YAML" ]; then
				$REFRESH_CMD
			fi
			;;
			(MOVE_SELF)
			if [ ! -e "${DIRECTORY}" ]; then
				$REFRESH_CMD
			fi
			;;
	esac
done
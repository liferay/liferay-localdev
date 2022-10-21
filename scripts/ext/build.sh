#!/usr/bin/env bash

set -e

REPO="${LOCALDEV_REPO:-/repo}"

# Check to see if tilt is up, if so tell that container to build, otherwise we can call build

TILT_CONTAINER=$(docker container list --format '{{json .}}' | jq -sr '.[] | select(.Names=="localdev-extension-runtime") | .Names')

if [ $# -eq 0 ]; then
  BUILD_CMD='/workspace/gradlew --project-dir /workspace clean build'
else
  BUILD_CMD="/workspace/gradlew --project-dir /workspace $@"
fi

# call the build command at appropriate location

if [ "$TILT_CONTAINER" != "" ]; then
  docker exec -i $TILT_CONTAINER sh -c "$BUILD_CMD"
else
  $BUILD_CMD
fi

# now we have built client extensions, search for the zips and then return in a string
for distZip in $(find /workspace/client-extensions -name '*.zip' -path '*/dist/*' 2>/dev/null); do
  echo $distZip | sed -e 's/\/workspace\/client-extensions\///'
done
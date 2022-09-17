#!/usr/bin/env bash

set -e

IMAGE=$1

if [ -z "$IMAGE" ]; then
  echo "Must specify image tag."
  exit 1
fi

# docker run
# setup volume binds
# setup port mappings
# setup extraHosts
# setup env vars
## KUBERNETES_SERVICE_HOST
## KUBERNETES_SERVICE_PORT
## KUBERNETES_NAMESPACE
## KUBERNETES_CERTIFICATE
## KUBERNETES_TOKEN
## dockerCreateContainer.withEnvVar("JPDA_ADDRESS", "0.0.0.0:8000");
## dockerCreateContainer.withEnvVar("LIFERAY_JPDA_ENABLED", "true");
## dockerCreateContainer.withEnvVar(_getEnvVarOverride("module.framework.properties.osgi.console"), "0.0.0.0:11311");
## dockerCreateContainer.withEnvVar( "LIFERAY_WORKSPACE_ENVIRONMENT", workspaceExtension.getEnvironment());
# setup network

docker run \
  --add-host 


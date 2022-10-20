#!/usr/bin/env bash

set -e

git clone \
  --branch mkcertIntegration \
  --depth 1 \
  https://github.com/gamerson/lcectl \
  ${LOCALDEV_REPO}/tests/work/lcectl

cd ${LOCALDEV_REPO}/tests/work/lcectl

./gow run main.go config set localdev.resources.dir ${LOCALDEV_REPO}

./gow run main.go config set localdev.resources.sync false

./gow run main.go runtime mkcert --install

./gow run main.go runtime mkcert

git clone \
  --branch jwt \
  --depth 1 \
  https://github.com/rotty3000/gartner-client-extensions-demo \
  ${LOCALDEV_REPO}/tests/work/gartner-client-extensions-demo

./gow run main.go runtime create -v

./gow run main.go ext start -d ${LOCALDEV_REPO}/tests/work/gartner-client-extensions-demo

FOUND_LOCALDEV_SERVER=0

until [ "$FOUND_LOCALDEV_SERVER" == "1" ]; do
  sleep 5
  FOUND_LOCALDEV_SERVER=$(docker ps | grep localdev-extension-runtime | wc -l)
  echo "FOUND_LOCALDEV_SERVER=${FOUND_LOCALDEV_SERVER}"
done

FOUND_EXT_PROVISION_CONFIG_MAPS=0

until [ "$FOUND_EXT_PROVISION_CONFIG_MAPS" == "5" ]; do
  sleep 5
  FOUND_EXT_PROVISION_CONFIG_MAPS=$(docker exec -i localdev-extension-runtime /entrypoint.sh kubectl get cm | grep ext-provision-metadata | wc -l | xargs)
  echo "FOUND_EXT_PROVISION_CONFIG_MAPS=${FOUND_EXT_PROVISION_CONFIG_MAPS}"
  docker logs -n 100 localdev-extension-runtime
done

FOUND_EXT_INIT_CONFIG_MAPS=0

until [ "$FOUND_EXT_INIT_CONFIG_MAPS" == "4" ]; do
  sleep 5
  FOUND_EXT_INIT_CONFIG_MAPS=$(docker exec -i localdev-extension-runtime /entrypoint.sh kubectl get cm | grep ext-init-metadata | wc -l | xargs)
  echo "FOUND_EXT_INIT_CONFIG_MAPS=${FOUND_EXT_INIT_CONFIG_MAPS}"
  docker logs -n 100 localdev-extension-runtime
done

./gow run main.go runtime delete
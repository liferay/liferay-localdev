#!/usr/bin/env bash

set -ex

set +e
RS=$(docker container stop dxp-server >/dev/null 2>&1)

echo "'dxp-server' stopped."
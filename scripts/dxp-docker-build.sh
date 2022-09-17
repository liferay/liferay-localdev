#!/usr/bin/env bash

set -e

TAG=$1

if [ -z "$TAG" ]; then
  echo "Must specify image tag."
  exit 1
fi

docker build -t $1 /repo/dxp
#!/usr/bin/env bash

set -e

/repo/scripts/runtime/start.sh

if /repo/scripts/ext/status.sh; then
  echo "'localdev' extension environment is already started."
  exit 0
fi

export DO_NOT_TRACK=1

tilt up -f /repo/tilt/Tiltfile

echo "'localdev' extension environment started."
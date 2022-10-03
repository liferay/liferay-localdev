#!/usr/bin/env bash

set -e

tilt trigger "(Tiltfile)" --host host.docker.internal

echo "'localdev' extension environment refreshed."
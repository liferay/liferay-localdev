#!/usr/bin/env bash

set -e

kubectl --context 'k3d-lxc-localdev' get secret default-token -o jsonpath='{.data.token}' | base64 --decode
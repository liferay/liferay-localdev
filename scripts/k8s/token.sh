#!/usr/bin/env bash

set -e

kubectl --context 'k3d-localdev' get secret default-token -o jsonpath='{.data.token}' | base64 --decode
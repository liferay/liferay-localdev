#!/usr/bin/env bash

set -e

ytt \
  -f ./k8s/extension \
  -f extensions/couponpdf/couponpdf.client-extension-config.json \
  --data-value cpu=500m \
  --data-value image=couponpdf \
  --data-value memory=512Mi \
  --data-value serviceId=couponpdf \
  --data-value-yaml debugPort=8001 \
  --data-value "virtualInstanceId=$1" \
  --data-value-yaml initMetadata=true
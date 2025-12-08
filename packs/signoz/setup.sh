#!/usr/bin/env bash
# Copyright IBM Corp. 2021, 2025
# SPDX-License-Identifier: MPL-2.0

set -eu

RELEASE=${RELEASE:-signoz}
NAMESPACE=${NAMESPACE:-default}
CLICKHOUSE_PASSWORD=${CLICKHOUSE_PASSWORD:-}

if [ ! -n "$CLICKHOUSE_PASSWORD" ]; then
    echo "ERROR: CLICKHOUSE_PASSWORD is unset"
    exit 1
fi

sed -e "s/NAMESPACE/${NAMESPACE}/" \
    -e "s/RELEASE/${RELEASE}/" \
    -e "s/PASSWORD/${CLICKHOUSE_PASSWORD}/" \
    ./specs/password.nv.hcl | nomad var put -in=hcl -

nomad volume create \
      -namespace "$NAMESPACE" \
      ./specs/volume-clickhouse.hcl

nomad volume create \
      -namespace "$NAMESPACE" \
      ./specs/volume-signoz.hcl

nomad volume create \
      -namespace "$NAMESPACE" \
      ./specs/volume-zookeeper.hcl

for job in signoz clickhouse otel_collector schema_migrator_sync schema_migrator_async;
do
    sed -e "s/NAMESPACE/${NAMESPACE}/" \
        -e "s/RELEASE/${RELEASE}/" \
        ./specs/policy.hcl | nomad acl policy apply \
                                   -namespace "$NAMESPACE" \
                                   -description "SigNoz Shared Variables policy" \
                                   -job "${RELEASE}_$job" \
                                   "${RELEASE}_$job" -

done

#!/usr/bin/env bash

# A script for ensuring that a single Nomad allocation of a job is
# running at one time.  Based on the Consul Learn Guide for
# application leader elections:
# https://learn.hashicorp.com/tutorials/consul/application-leader-elections
#
# This script is designed to be run a prestart sidecar. If it exits it
# will release the lock (or the lock's TTL will expire). The main task
# should block waiting for a directory to appear named
# "${NOMAD_ALLOC_DIR}/${NOMAD_ALLOC_ID}.lock"
#
# To adapt this script for transitioning leader elections, we recommend
# using something other than shell scripts. =)

set -e

CONSUL_ADDR=${CONSUL_ADDR:-"http://localhost:8500"}
NOMAD_JOB_ID=${NOMAD_JOB_ID:-example}
NOMAD_ALLOC_ID=${NOMAD_ALLOC_ID:-$(uuidgen)}
NOMAD_ALLOC_DIR=${NOMAD_ALLOC_DIR:-./alloc}
TTL_IN_SEC=${TTL_IN_SEC:-10}
LEADER_KEY=${LEADER_KEY:-leader}
REFRESH_WINDOW=$(( $TTL_IN_SEC / 2))

# obtain a unique session identifier for this allocation. This has the
# name of the job so that operators can easily determine all the open
# sessions across the job
session_body=$(printf '{"Name": "%s", "TTL": "%ss"}' "$NOMAD_JOB_ID" "$TTL_IN_SEC")
session_id=$(curl -s \
                  -X PUT \
                  --fail \
                  -d "$session_body" \
                  "$CONSUL_ADDR/v1/session/create" | jq -r '.ID')

trap release EXIT

# release the session when this script exits. But we use a TTL on the
# session so that we don't have to rely on this script never failing
# to avoid deadlocking
release() {
    echo "releasing session $session_id"
    curl --fail -X PUT "$CONSUL_ADDR/v1/kv/$LEADER_KEY?release=$session_id"
}

# try to obtain the lock
try_lock() {
    ok=$(curl -s -X PUT \
              -d "$NOMAD_ALLOC_ID" \
              "$CONSUL_ADDR/v1/kv/$LEADER_KEY?acquire=$session_id")

    if [[ "$ok" == "true" ]]; then
        echo "got session lock $session_id"
        mkdir "${NOMAD_ALLOC_DIR}/${NOMAD_ALLOC_ID}.lock"
        refresh
    fi
}

# refresh the TTL at half the TTL length
refresh() {
    echo "refreshing session every $REFRESH_WINDOW seconds"
    while :
          do
              sleep $REFRESH_WINDOW
              curl --fail -s \
                   -o /dev/null \
                   -X PUT \
                   "$CONSUL_ADDR/v1/session/renew/$session_id"
    done
}

# we didn't obtain the lock, so poll the key at half the TTL length to
# see if we can get it later
poll() {
    index="1"
    echo "polling for session to be released every $REFRESH_WINDOW seconds"
    while :
    do
        resp=$(curl -s -X GET \
                    -H "X-Consul-Index: $index" \
                    "$CONSUL_ADDR/v1/kv/$LEADER_KEY")
        if [[ $(echo "$resp" | jq -r '.[0].Session') == "null" ]];
        then
            try_lock
        fi

        # we have to keep our session refreshed
        curl --fail -s \
             -o /dev/null \
             -X PUT \
             "$CONSUL_ADDR/v1/session/renew/$session_id"

        index=$(echo "$resp" | jq -r '.[0].ModifyIndex')
        sleep $REFRESH_WINDOW
    done
}

try_lock
poll

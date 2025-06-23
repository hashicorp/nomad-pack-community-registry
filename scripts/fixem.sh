#!/usr/bin/env bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


test -d packs || {
  echo 'please run this from the repo root'
  exit 1
}

# these are more trouble than they're worth at the moment
problem_children=''
# complex templating
problem_children="$problem_children|democratic_csi_nfs"
problem_children="$problem_children|rabbitmq"
# odd `$vars := .$pack` construction
problem_children="$problem_children|opentelemetry_collector"
problem_children="$problem_children|prometheus_snmp_exporter"

mkdir -p fixlogs

ls packs | while read -r p; do
  if [[ "^($problem_children)$" =~ "$p" ]]; then
    echo "🟨 $p"
    continue
  fi
  "$(dirname $0)/update-parser-v2.sh" "packs/$p" "$p" 2>&1 >> "./fixlogs/$p.log" && printf "💚" || printf "⭕"
  printf " $p\n"
done

tail fixlogs/* | grep -E '(Error|Filename|Position).*'

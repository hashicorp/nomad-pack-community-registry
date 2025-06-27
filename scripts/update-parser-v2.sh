#!/usr/bin/env bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


set -u

if [ $# -ne 2 ]; then
    cat <<EOF
Update common nomad-pack parser v1 syntax to v2.

Usage: $0 <path> <pack name>

E.g.: $0 ./packs/hello_world hello_world
EOF
    exit 1
fi

path="$1"
test -d "$path"
pack="$2"

mkdir -p fixlogs
log="./fixlogs/$pack.log"
# output `set -x` to a log file
exec 19>"$log"
BASH_XTRACEFD=19
set -x

replace() {
  local f="$1"
  # meta vars
  # meta "pack.var" .
  sed -i -r 's~\.nomad_pack\.([0-9a-z_\.]+)~meta "\1" .~g' "$f"
  # pack vars
  # var "some_var" .
  sed -i -r "s~\.($pack|my)\.([0-9a-z_\.]+)~var \"\2\" .~g" "$f"
  # parentheses
  # (var "some_var" .)
  sed -i -r 's~(not|eq|ne|keys|prepend) var "([0-9a-z_\.]+)"\s+(\S+)~\1 (var "\2" \3)~g' "$f"
  # template
  # template "tmpl_name" .
  sed -i -r "s~(template \"[0-9a-z_]+\"\s+\.)$pack~\1~g" "$f"

  # BELOW HERE IS MADNESS, err increasingly specific

  # printf for nomad autoscaler
  sed -i -r 's~(printf "\S+")\s+(var \S+ \.)~\1 (\2)~g' "$f"

  # more var - inline var references without a prefixed ".$pack"
  # note: this can be overzealous within a [[ define ... ]] template definition
  sed -i -r 's~(\[\[[-\s]+ if)\s+\.([0-9a-z_\.]+)~\1 var "\2" .~g' "$f"
  sed -i -r 's~(\[\[)\s+\.([0-9a-z_\.]+)~\1 var "\2" .~g' "$f"

  # checking two variables (kibana, democratic_csi_nfs)
  sed -i -r 's~(and|all) (var "[0-9a-z_\.]+" \.) (var "[0-9a-z_\.]+" \.)~\1 (\2) (\3)~' "$f"

  # assignment (opentelemetry_collector, prometheus_snmp_exporter, rabbitmq)
  sed -i -r 's~(\[\[.*:=\s+)\.([0-9a-z_\]+)~\1var "\2" .~g' "$f"
}

find "$path" -type f -name '*.tpl' | while read -r tpl; do
  replace "$tpl"
done

set -e

$(dirname $0)/validate.sh "$path"

# delete the log if all went well
rm "$log"

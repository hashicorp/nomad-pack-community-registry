#!/usr/bin/env bash

set -u

pack="$1"

mkdir -p fixlogs
# output `set -x` to a log file
exec 19>./fixlogs/$pack.log
BASH_XTRACEFD=19
set -x

d="packs/$pack"
test -d "$d"

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
  sed -i -r 's~(not|eq|ne|len|keys|prepend) var "([0-9a-z_\.]+)"\s+(\S+)~\1 (var "\2" \3)~g' "$f"
  # template
  # template "tmpl_name" .
  sed -i -r "s~(template \"[0-9a-z_]+\"\s+\.)$pack~\1~g" "$f"

  # BELOW HERE IS MADNESS, err increasingly specific

  # printf for nomad autoscaler
  sed -i -r 's~(printf "\S+")\s+(var \S+ \.)~\1 (\2)~g' "$f"

  # more var - inline var references without a prefixed ".$pack"
  sed -i -r 's~(\[\[[-\s]+ if)\s+\.([0-9a-z_\.]+)~\1 var "\2" .~g' "$f"
  sed -i -r 's~(\[\[)\s+\.([0-9a-z_\.]+)~\1 var "\2" .~g' "$f"

  # checking two variables (kibana, democratic_csi_nfs)
  sed -i -r 's~(and|all) (var "[0-9a-z_\.]+" \.) (var "[0-9a-z_\.]+" \.)~\1 (\2) (\3)~' "$f"

  # assignment (opentelemetry_collector, prometheus_snmp_exporter, rabbitmq)
  sed -i -r 's~(\[\[.*:=\s+)\.([0-9a-z_\]+)~\1var "\2" .~g' "$f"
}

find "$d" -type f -name '*.tpl' | while read -r tpl; do
  replace "$tpl"
done

set -e

mkdir -p rendered fixlogs
nomad-pack render "./packs/$pack" -o ./rendered 2>&1 >> "./fixlogs/$pack.log"
#nomad-pack render --no-format "./packs/$pack" -o ./rendered 2>&1 >> "./fixlogs/$pack.log"
#nomad fmt -check -recursive "./rendered/$pack" 2>&1 >> "./fixlogs/$pack.log"
# delete the log if all went well
rm "./fixlogs/$pack.log"

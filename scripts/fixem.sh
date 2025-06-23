#!/usr/bin/env bash

test -d packs || {
  echo 'please run this from the repo root'
  exit 1
}

mkdir -p fixlogs

ls packs | while read -r p; do
  "$(dirname $0)/update-parser-v2.sh" "packs/$p" "$p" 2>&1 >> "./fixlogs/$p.log" && printf "💚" || printf "⭕"
  printf " $p\n"
done

tail fixlogs/* | grep -E '(Error|Filename|Position).*'

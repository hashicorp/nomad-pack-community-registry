#!/usr/bin/env bash

set -x
git co packs
find ./packs -name '*.bak' -exec rm -v {} \;
rm -rfv fixlogs rendered

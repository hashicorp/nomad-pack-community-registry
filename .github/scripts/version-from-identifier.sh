# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# #!/usr/bin/env bash
metadataFile="$(grep -R "\"$1\"" ./packs | cut -d ' ' -f1 | sed 's/:.*//g')"
if [[ -f "$metadataFile" ]]; then
  versionLine="$(cat "$metadataFile" | grep "version.*=.*\".*\"")"
  version="$(echo "$versionLine" | sed -E 's/.*\"(.*)\"/\1/g')"
  echo $version
fi

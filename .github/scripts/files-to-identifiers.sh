# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# #!/usr/bin/env bash
#
# This script coerces a list of input files that have been changed
# into a list of integration identifiers. If a pack file is passed in
# but the pack does not have an integration identifier specified,
# nothing is returned. If multiple files of a single pack are passed in,
# only one instance of the packs identifier will be returned.
changedFiles=$(while IFS= read line; do echo "$line"; done)
changedDirs=$(echo "$changedFiles" | sed -E 's/packs\/([^\/]*).*/\1/g')
changedDirsUniq=$(echo "$changedDirs" | sort | uniq)

# For each unique directory passed in
for changed_dir in $(echo $changedDirsUniq); do
  # Verify that the `metadata.hcl` file exists
  metadataFile="./packs/$changed_dir/metadata.hcl"
  if [[ -f "$metadataFile" ]]; then
      # Verify that the `identifier` is specified
      identifierLine="$(cat "$metadataFile" | grep "identifier.*=.*\".*\"")"
      if [[ "$identifierLine" != "" ]]; then
          # Parse out the `identifier` value
          identifier="$(echo "$identifierLine" | sed -E 's/.*\"(.*)\"/\1/g')"
          echo "$identifier"
      fi
  fi
done

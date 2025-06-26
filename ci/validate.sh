#!/usr/bin/env bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

set -u

if [ $# -lt 1 ]; then
    cat <<EOF
Validate pack(s) with:
 * nomad-pack render
 * nomad fmt
 * nomad validate

Usage: $0 ./packs/path-to-pack

Packs render to the ./rendered/ dir for inspection
if validation fails.
EOF
    exit 1
fi

path="$1"
pack="$(basename "$1")" # lazy assumption

set -exo pipefail

mkdir -p rendered

validate() {
    local render_flags="${1:-}"
    # `nomad-pack render` catches pack templating errors
    nomad-pack render $render_flags -o ./rendered "$path"

    find "./rendered/$pack" -type f -name '*.nomad' -or -name '*.hcl' \
    | while read -r job; do
        # `nomad fmt` catches syntax errors in the rendered hcl
        nomad fmt "$job"
        # `nomad validate` catches semantic jobspec issues,
        # especially if run against a live nomad agent.
        nomad validate "$job"
    done

    # if all goes well, delete reference files
    rm -rf "./rendered/$pack"
}

# run with different var files, if present
if [ -d "$path/.ci" ]; then
    find "$path/.ci" -type f -name 'vars-*.hcl' \
    | while read -r var_file; do
        cat "$var_file"
        validate "--var-file $var_file"
    done
else
    # otherwise, validate with no vars
    validate
fi

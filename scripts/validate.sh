#!/usr/bin/env bash

set -u

if [ $# -lt 1 ]; then
    cat <<EOF
Validate pack(s) with:
 * nomad-pack render
 * nomad fmt
 * nomad validate

Usage: $0 ./path-to-pack
   or: $0 all

Packs render to the ./rendered/ dir,
and logs go in ./validated/

If validation is successful, both rendered/{pack}
and validated/{pack}.log are removed, so only
failures are retained for inspection.
EOF
    exit 1
fi

if [ "$1" == 'all' ]; then
    ls packs | while read -r p; do
        "$0" "./packs/$p"
    done
    ls validated | while read -r l; do
        echo "${l/.log/}"
        cat "validated/$l"
    done | grep . && exit 1
    exit 0
fi

path="$1"
pack="$(basename "$1")" # lazy assumption

tmpdir="$(mktemp --directory --tmpdir=$path)"
trap "rm -rf $tmpdir" EXIT

mkdir -p validated rendered
log="./validated/$pack.log"
# output `set -x` to a log file
exec 19>"$log"
BASH_XTRACEFD=19

set -exo pipefail

# HACK: set required vars for select packs
case "$pack" in
    'csi_openstack_cinder')
        # needs a real file due to template doing a fileContents call
        echo 'pretend-config' > "$tmpdir/cinder.conf"
        export NOMAD_PACK_VAR_cloud_conf_file="$tmpdir/cinder.conf"
        ;;
    'tfc_agent')
        export NOMAD_PACK_VAR_agent_token='not-a-real-token'
	;;
    'tfe_fdo_nomad')
        export NOMAD_PACK_VAR_tfe_hostname='localhost'
        export NOMAD_PACK_VAR_tfe_database_host='localhost'
        export NOMAD_PACK_VAR_tfe_object_storage_s3_endpoint='s3-fakery'
        export NOMAD_PACK_VAR_tfe_object_storage_s3_access_key_id='s3-fake-id'
        export NOMAD_PACK_VAR_tfe_redis_host='localhost'
        # these aren't required, but default to non-existent namespaces
        export NOMAD_PACK_VAR_tfe_namespace='default'
        export NOMAD_PACK_VAR_tfe_agent_namespace='default'
        ;;
    'democratic_csi_nfs')
	export NOMAD_PACK_VAR_nfs_controller_mount_path='/tmp/nfs-mount'
	export NOMAD_PACK_VAR_nfs_share_host='localhost'
	export NOMAD_PACK_VAR_nfs_share_base_path='/export'
	;;
esac

# `nomad-pack render` catches pack templating errors
nomad-pack render -o ./rendered "$path" 2>&1 >> "$log"
find "./rendered/$pack" -type f -name '*.nomad' -or -name '*.hcl' \
| while read -r job; do
    # `nomad fmt` catches syntax errors in the rendered hcl
    nomad fmt "$job" 2>&1 | tee -a "$log"
    # `nomad validate` catches real jobspec issues
    nomad validate "$job" 2>&1 | tee -a "$log"
done

# if all goes well, delete reference files
rm -rf "./rendered/$pack"
rm "$log"

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# packs/nomad_debug_bundle/outputs.tpl

Nomad Debug Bundle deployed successfully!

  Job name   : [[ var "job_name" . ]]
  Schedule   : [[ var "cron_schedule" . ]] (UTC)
  Duration   : [[ var "debug_duration" . ]]
  Servers    : [[ var "server_id" . ]]
  Nodes      : [[ var "node_id" . ]]
  Output dir : [[ var "output_dir" . ]]
  Retention  : [[ var "retention_days" . ]] days

Debug bundles will be saved as timestamped .tar.gz files under the output directory on the host.

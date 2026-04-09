# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# templates/nomad_debug_bundle.nomad.tpl

job "[[ var "job_name" . ]]" {
  type        = "batch"
  region      = "[[ var "region" . ]]"
  datacenters = [[ var "datacenters" . | toStringList ]]

  periodic {
    crons             = ["[[ var "cron_schedule" . ]]"]
    prohibit_overlap = [[ var "prohibit_overlap" . ]]
    time_zone        = "Asia/Kolkata"
  }

  # Prevent Nomad from rescheduling failed runs automatically
  reschedule {
    attempts  = 0
    unlimited = false
  }

  group "debug-bundle" {
    count = 1

    restart {
      attempts = 2
      interval = "10m"
      delay    = "30s"
      mode     = "fail"
    }

    task "run-debug" {
      driver = "raw_exec"

      # raw_exec runs directly on the host — the nomad binary and output
      # directory must exist on whichever client node schedules this task.
      config {
        command = "/bin/bash"
        args = [
          "-c",
          <<EOF
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_DIR=[[ var "output_dir" . ]]/$TIMESTAMP

mkdir -p $OUTPUT_DIR

[[ var "nomad_binary" . ]] operator debug \
-duration=[[ var "debug_duration" . ]] \
-interval=[[ var "debug_interval" . ]] \
-server-id=[[ var "server_id" . ]] \
-node-id=[[ var "node_id" . ]] \
-output=$OUTPUT_DIR \
-address=[[ var "nomad_addr" . ]]

echo "Debug bundle saved to $OUTPUT_DIR"
EOF
        ]
      }

      env {
        NOMAD_ADDR  = "[[ var "nomad_addr" . ]]"
        [[ if ne (var "nomad_token" .) "" -]]
        NOMAD_TOKEN = "[[ var "nomad_token" . ]]"
        [[- end ]]
      }

      resources {
        cpu    = [[ var "cpu" . ]]
        memory = [[ var "memory" . ]]
      }
    }
  }
}

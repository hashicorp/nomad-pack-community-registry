# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

job "[[ var "job_name" . ]]" {
  type        = "service"
  region      = "[[ var "region" . ]]"
  namespace   = "[[ var "namespace" . ]]"
  datacenters = [[ var "datacenters" . | toStringList ]]

  update {
    max_parallel      = 1
    min_healthy_time  = "30s"
    healthy_deadline  = "5m"
    progress_deadline = "10m"
    auto_revert       = true
  }

  group "snapshot-agent" {
    count = 1

    restart {
      attempts = [[ var "restart_attempts" . ]]
      interval = "[[ var "restart_interval" . ]]"
      delay    = "30s"
      mode     = "fail"
    }

    task "snapshot-agent" {
      driver = "raw_exec"

      # Renders the snapshot agent HCL config from variables at deploy time.
      # change_mode = restart ensures a re-deploy picks up credential/config changes.
      template {
        data        = <<EOF
[[ template "snapshot_agent_config" . ]]
EOF
        destination = "local/snapshot-agent.hcl"
        change_mode = "restart"
      }

      config {
        command = "[[ var "nomad_binary" . ]]"
        args = [
          "operator",
          "snapshot",
          "agent",
          "-log-level=[[ var "log_level" . ]]",
          [[ if var "log_json" . ]]"-log-json",[[ end ]]
          "${NOMAD_TASK_DIR}/snapshot-agent.hcl",
        ]
      }

      # Environment variables
      # Credentials are injected per backend. For AWS and GCS, leaving the
      # explicit credential variables empty causes the agent to fall back to
      # instance/workload identity — the recommended approach on cloud VMs.
      env {
        NOMAD_ADDR = "[[ var "nomad_addr" . ]]"

        [[ if ne (var "nomad_token" .) "" ]]
        NOMAD_TOKEN = "[[ var "nomad_token" . ]]"
        [[ end ]]

        [[ if eq (var "storage_backend" .) "s3" ]]
        # AWS — only set if explicit keys are provided.
        # Leave both empty to use EC2/ECS instance role instead.
        [[ if ne (var "aws_access_key_id" .) "" ]]
        AWS_ACCESS_KEY_ID     = "[[ var "aws_access_key_id" . ]]"
        AWS_SECRET_ACCESS_KEY = "[[ var "aws_secret_access_key" . ]]"
        AWS_SESSION_TOKEN     = "[[ var "aws_session_token" . ]]"
        [[ end ]]
        [[ if ne (var "aws_s3_endpoint" .) "" ]]
        AWS_S3_ENDPOINT = "[[ var "aws_s3_endpoint" . ]]"
        [[ end ]]
        [[ end ]]

        [[ if eq (var "storage_backend" .) "gcs" ]]
        # GCS — only set if a service account JSON path is provided.
        # Leave empty to use the GCE instance service account instead.
        [[ if ne (var "gcs_credentials_file" .) "" ]]
        GOOGLE_APPLICATION_CREDENTIALS = "[[ var "gcs_credentials_file" . ]]"
        [[ end ]]
        [[ end ]]

        [[ if eq (var "storage_backend" .) "azure" ]]
        # Azure does not support instance identity in the snapshot agent.
        # account_name and account_key must always be provided explicitly.
        AZURE_STORAGE_ACCOUNT = "[[ var "azure_account_name" . ]]"
        AZURE_STORAGE_KEY     = "[[ var "azure_account_key" . ]]"
        [[ end ]]
      }

      service {
        name     = "nomad-snapshot-agent"
        provider = "nomad"
      }

      resources {
        cpu    = [[ var "cpu" . ]]
        memory = [[ var "memory" . ]]
        [[ if gt (var "memory_max" .) 0 ]]
        memory_max = [[ var "memory_max" . ]]
        [[ end ]]
      }

      logs {
        max_files     = 5
        max_file_size = 10
      }
    }
  }
}

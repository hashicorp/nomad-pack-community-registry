job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  [[ template "datacenters" . ]]
  [[ template "namespace" . ]]
  type = "service"

  group "tfc-agent" {
    count = [[ var "count" . ]]

    task "tfc-agent" {
      driver = "docker"

      config {
        image = "hashicorp/tfc-agent:[[ var "agent_version" . ]]"
      }

      [[ if var "agent_otlp_cert" . -]]
      artifact {
        source = [[ var "agent_otlp_cert" . | quote ]]
        destination = [[ template "otlp_cert_file" . ]]
      }
      [[ end ]]

      env {
        TFC_AGENT_TOKEN          = [[ var "agent_token" . | quote ]]
        TFC_ADDRESS              = [[ var "tfc_address" . | quote ]]
        TFC_AGENT_NAME           = [[ var "agent_name" . | quote ]]
        TFC_AGENT_AUTO_UPDATE    = [[ var "agent_auto_update" . | quote ]]
        TFC_AGENT_LOG_LEVEL      = [[ var "agent_log_level" . | quote ]]
        TFC_AGENT_LOG_JSON       = [[ var "agent_log_json" . | quote ]]
        TFC_AGENT_SINGLE         = [[ var "agent_single" . | quote ]]
        TFC_AGENT_OTLP_ADDRESS   = [[ var "agent_otlp_address" . | quote ]]
        TFC_AGENT_OTLP_CERT_FILE = [[ template "otlp_cert_file" . ]]
      }

      resources {
        cpu    = [[ var "resources.cpu" . ]]
        memory = [[ var "resources.memory" . ]]
      }

      # Allow the tfc-agent to drain its own work gracefully when asked to
      # shut down. Draining tfc-agent work may include waiting for a Terraform
      # plan or apply operation to finish, thus the generous window.
      kill_timeout = "2h"
    }
    update {
      # progress_deadline must be >= kill_timeout
      progress_deadline = "2h"
    }
  }
}

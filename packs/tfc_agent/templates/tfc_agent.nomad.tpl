job "tfc-agent" {
  [[ template "region" . ]]
  [[ template "datacenters" . ]]
  [[ template "namespace" . ]]
  type = "service"

  group "tfc-agent" {
    count = [[ .tfc_agent.count ]]

    task "tfc-agent" {
      driver = "docker"

      config {
        image = "hashicorp/tfc-agent:[[ .tfc_agent.agent_version ]]"
      }

      [[ if .tfc_agent.agent_otlp_cert -]]
      artifact {
        source = [[ .tfc_agent.agent_otlp_cert | quote ]]
        destination = [[ template "otlp_cert_file" . ]]
      }
      [[ end ]]

      env {
        TFC_AGENT_TOKEN          = [[ .tfc_agent.agent_token | quote ]]
        TFC_ADDRESS              = [[ .tfc_agent.tfc_address | quote ]]
        TFC_AGENT_NAME           = [[ .tfc_agent.agent_name | quote ]]
        TFC_AGENT_AUTO_UPDATE    = [[ .tfc_agent.agent_auto_update | quote ]]
        TFC_AGENT_LOG_LEVEL      = [[ .tfc_agent.agent_log_level | quote ]]
        TFC_AGENT_LOG_JSON       = [[ .tfc_agent.agent_log_json | quote ]]
        TFC_AGENT_SINGLE         = [[ .tfc_agent.agent_single | quote ]]
        TFC_AGENT_OTLP_ADDRESS   = [[ .tfc_agent.agent_otlp_address | quote ]]
        TFC_AGENT_OTLP_CERT_FILE = [[ template "otlp_cert_file" . ]]
      }

      resources {
        cpu    = [[ .tfc_agent.resources.cpu ]]
        memory = [[ .tfc_agent.resources.memory ]]
      }

      kill_timeout = "2h"
    }
  }
}

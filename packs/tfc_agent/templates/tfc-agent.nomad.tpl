job "tfc-agent" {
  region      = [[ .tfc_agent.region | quote ]]
  datacenters = [ [[ range $idx, $dc := .tfc_agent.datacenters ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]
  namespace   = [[ .tfc_agent.namespace | quote ]]
  type        = "service"

  group "tfc-agent" {
    count = [[ .tfc_agent.count ]]

    task "tfc-agent" {
      driver = "docker"

      config {
        image = "hashicorp/tfc-agent:[[ .tfc_agent.agent_version ]]"

        [[ if .tfc_agent.agent_otlp_cert_file ]]
        mounts = [
          {
            type = "bind"
            source = [[ .tfc_agent.agent_otlp_cert_file | quote ]]
            target = "/home/tfc-agent/certs/otlp.pem"
            readonly = true
          }
        ]
        [[ end ]]
      }

      env {
        TFC_ADDRESS            = [[ .tfc_agent.tfc_address | quote ]]
        TFC_AGENT_TOKEN        = [[ .tfc_agent.agent_token | quote ]]
        TFC_AGENT_NAME         = [[ .tfc_agent.agent_name | quote ]]
        TFC_AGENT_AUTO_UPDATE  = [[ .tfc_agent.agent_auto_update | quote ]]
        TFC_AGENT_OTLP_ADDRESS = [[ .tfc_agent.agent_otlp_address | quote ]]
        TFC_AGENT_LOG_LEVEL    = [[ .tfc_agent.agent_log_level | quote ]]

        [[ if .tfc_agent.agent_log_json ]]TFC_AGENT_LOG_JSON = "true"[[end]]
        [[ if .tfc_agent.agent_otlp_cert_file ]]TFC_AGENT_OTLP_CERT_FILE = "certs/otlp.pem"[[end]]
      }

      resources {
        cpu    = [[ .tfc_agent.resources.cpu ]]
        memory = [[ .tfc_agent.resources.memory ]]
      }

      kill_timeout = "2h"
    }
  }
}

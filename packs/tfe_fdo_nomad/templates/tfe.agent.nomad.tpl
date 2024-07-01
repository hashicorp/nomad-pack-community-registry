# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

job "tfe-agent-job" {
  type      = "batch"
  namespace = [[ .tfe_fdo_nomad.tfe_agent_namespace | quote ]]
  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }
  parameterized {
    payload       = "forbidden"
    meta_required = [
      "TFC_AGENT_TOKEN",
      "TFC_ADDRESS"
    ]
    meta_optional = [
      "TFE_RUN_PIPELINE_IMAGE",
      "TFC_AGENT_AUTO_UPDATE",
      "TFC_AGENT_CACHE_DIR",
      "TFC_AGENT_SINGLE",
      "HTTPS_PROXY",
      "HTTP_PROXY",
      "NO_PROXY"
    ]
  }  

  group "tfe-agent-group" {

    task "tfc-agent-task" {
      driver = "docker"
  
      config {
        image = [[ .tfe_fdo_nomad.tfe_agent_image | quote ]]
      }

      env {
        TFC_ADDRESS           = "${NOMAD_META_TFC_ADDRESS}"
        TFC_AGENT_TOKEN       = "${NOMAD_META_TFC_AGENT_TOKEN}"
        TFC_AGENT_AUTO_UPDATE = "${NOMAD_META_TFC_AGENT_AUTO_UPDATE}"
        TFC_AGENT_CACHE_DIR   = "${NOMAD_META_TFC_AGENT_CACHE_DIR}"
        TFC_AGENT_SINGLE      = "${NOMAD_META_TFC_AGENT_SINGLE}"
        HTTPS_PROXY           = "${NOMAD_META_HTTPS_PROXY}"
        https_proxy           = "${NOMAD_META_HTTPS_PROXY}"
        HTTP_PROXY            = "${NOMAD_META_HTTP_PROXY}"
        http_proxy            = "${NOMAD_META_HTTP_PROXY}"
        NO_PROXY              = "${NOMAD_META_NO_PROXY}"
        no_proxy              = "${NOMAD_META_NO_PROXY}"
      }

      resources {
        cpu    = [[ .tfe_fdo_nomad.tfe_agent_resource_cpu ]]
        memory = [[ .tfe_fdo_nomad.tfe_agent_resource_memory ]]
      }
    }
  }
}

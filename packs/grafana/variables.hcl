# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name"
  type        = string
  default = ""
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement"
  type        = list(string)
  default     = ["dc1"]
}

variable "node_pool" {
  description = "The node pool where the job should be placed."
  type        = string
  default     = "default"
}

variable "region" {
  description = "The region where the job should be placed"
  type        = string
  default     = "global"
}

variable "dns" {
  description = ""
  type = object({
    servers   = list(string)
    searches = list(string)
    options = list(string)
  })
  default = {}
}

variable "grafana_version_tag" {
  description = "The docker image version. For options, see https://hub.docker.com/grafana/grafana"
  type        = string
  default     = "latest"
}

variable "grafana_http_port" {
  description = "The Nomad client port that routes to the Grafana"
  type        = number
  default     = 3000
}

variable "grafana_upstreams" {
  description = ""

  type = list(object({
    name = string
    port = number
  }))
  default = []
}

variable "grafana_resources" {
  description = "The resource to assign to the Grafana service task"
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 200,
    memory = 256
  }
}

variable "grafana_consul_tags" {
  description = ""
  type = list(string)
  default = []
}

variable "grafana_vault" {
  description = "List of Vault Policies"
  type = list(string)
  default = []
  }

variable "grafana_volume" {
  description = "The resource to assign to the Grafana service task"
  type = object({
    type    = string
    source = string
  })
  default = {}
}

variable "grafana_task_config_ini" {
  description = "ini string for grafana.ini"
  type = string
  default = ""
}

variable "grafana_env_vars" {
  description = ""
  type = list(object({
    key   = string
    value = string
  }))
  default = [
    {key = "GF_LOG_LEVEL", value = "DEBUG"},
    {key = "GF_LOG_MODE", value = "console"},
    {key = "GF_SERVER_HTTP_PORT", value = "$${NOMAD_PORT_http}"},
    {key = "GF_PATHS_PROVISIONING", value = "/local/grafana/provisioning"},
    {key = "GF_PATHS_CONFIG", value = "/local/grafana/grafana.ini"}
  ]
}

variable "grafana_task_artifacts" {
  description = "Define external artifacts for Grafana."
  type = list(object({
    source   = string
    destination = string
    mode   = string
    options = map(string)
  }))
  default = [
    {
      source = "https://grafana.com/api/dashboards/1860/revisions/26/download",
      destination = "local/grafana/provisioning/dashboards/linux/linux-node-exporter.json"
      mode = "file"
      options = null
    },
  ]
}

variable "grafana_task_config_dashboards" {
  description = "The yaml configuration for automatic provision of dashboards"
  type        = string
  default     = <<EOF
apiVersion: 1

providers:
  - name: dashboards
    type: file
    updateIntervalSeconds: 30
    options:
      foldersFromFilesStructure: true
      path: /local/grafana/provisioning/dashboards
EOF
}

variable "grafana_task_config_datasources" {
  description = "The yaml configuration for automatic provision of datasources"
  type        = string
  default     = <<EOF
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus.service.{{ env "NOMAD_DC" }}.consul:9090
    jsonData:
      exemplarTraceIdDestinations:
        - name: traceID
          datasourceUid: tempo
  - name: Tempo
    type: tempo
    access: proxy
    url: http://tempo.service.{{ env "NOMAD_DC" }}.consul:3200
    uid: tempo
  - name: Loki
    type: loki
    access: proxy
    url: http://loki.service.{{ env "NOMAD_DC" }}.consul:3100
    jsonData:
      derivedFields:
        - datasourceUid: tempo
          matcherRegex: (?:traceID|trace_id)=(\w+)
          name: TraceID
          url: $$${__value.raw}
EOF
}

variable "grafana_task_config_plugins" {
  description = "The yaml configuration for automatic provision of plugins"
  type        = string
  default     = ""
}

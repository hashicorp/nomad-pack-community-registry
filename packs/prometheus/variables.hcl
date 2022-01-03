variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name."
  type        = string
  default     = ""
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for job placement."
  type        = list(string)
  default     = ["dc1"]
}

variable "region" {
  description = "The region where the job should be placed."
  type        = string
  default     = "global"
}

variable "namespace" {
  description = "The namespace where the job should be placed."
  type        = string
  default     = "default"
}

variable "constraints" {
  description = "Constraints to apply to the entire job."
  type        = list(object({
    attribute = string
    operator  = string
    value     = string
  }))
  default = [
    {
      attribute = "$${attr.kernel.name}",
      value     = "linux",
      operator  = "",
    },
  ]
}

variable "prometheus_group_network" {
  description = "The Prometheus network configuration options."
  type        = object({
    mode  = string
    ports = map(number)
  })
  default = {
    mode  = "bridge",
    ports = {
      "http" = 9090,
    },
  }
}

variable "prometheus_task" {
  description = "Details configuration options for the Prometheus task."
  type        = object({
    driver   = string
    version  = string
    cli_args = list(string)
  })
  default = {
    driver   = "docker",
    version  = "2.30.2",
    cli_args = [
      "--config.file=/etc/prometheus/config/prometheus.yml",
      "--storage.tsdb.path=/prometheus",
      "--web.listen-address=0.0.0.0:9090",
      "--web.console.libraries=/usr/share/prometheus/console_libraries",
      "--web.console.templates=/usr/share/prometheus/consoles",
    ]
  }
}

variable "prometheus_task_app_prometheus_yaml" {
  description = "The Prometheus configuration to pass to the task."
  type        = string
  default     = <<EOF
---
global:
  scrape_interval: 30s
  evaluation_interval: 3s

rule_files:
  - rules.yml

alerting:
 alertmanagers:
    - consul_sd_configs:
      - server: {{ env "attr.unique.network.ip-address" }}:8500
        services:
        - alertmanager

scrape_configs:
  - job_name: prometheus
    static_configs:
    - targets:
      - 0.0.0.0:9090
  - job_name: "nomad_server"
    metrics_path: "/v1/metrics"
    params:
      format:
      - "prometheus"
    consul_sd_configs:
    - server: "{{ env "attr.unique.network.ip-address" }}:8500"
      services:
        - "nomad"
      tags:
        - "http"
  - job_name: "nomad_client"
    metrics_path: "/v1/metrics"
    params:
      format:
      - "prometheus"
    consul_sd_configs:
    - server: "{{ env "attr.unique.network.ip-address" }}:8500"
      services:
        - "nomad-client"
EOF
}

variable "prometheus_task_app_rules_yaml" {
  description = "Yaml configuration for the alerts to setup in prometheus."
  type        = string
  default     = ""
}

variable "prometheus_task_resources" {
  description = "The resource to assign to the Prometheus task."
  type        = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 500,
    memory = 256,
  }
}

variable "prometheus_task_services" {
  description = "Configuration options of the Prometheus services and checks."
  type        = list(object({
    service_port_label = string
    service_name       = string
    service_tags       = list(string)
    check_enabled      = bool
    check_path         = string
    check_interval     = string
    check_timeout      = string
  }))
  default = [{
    service_port_label = "http",
    service_name       = "prometheus",
    service_tags       = [],
    check_enabled      = true,
    check_path         = "/-/healthy",
    check_interval     = "3s",
    check_timeout      = "1s",
  }]
}

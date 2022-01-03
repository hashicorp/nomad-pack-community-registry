variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name."
  type        = string
  default     = ""
}

variable "count" {
  description = "How many instances to start."
  type        = string
  default     = "1"
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

variable "container_args" {
  description = "Arguments passed to the alertmanager docker container"
  type        = list(string)
  default = [
    "--config.file=/etc/alertmanager/config/alertmanager.yml",
  ]
}

variable "alertmanager_group_network" {
  description = "The node exporter network configuration options."
  type        = object({
    mode  = string
    ports = map(number)
  })
  default = {
    mode  = "bridge",
    ports = {
      "http" = 9093,
    },
  }
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement."
  type        = list(string)
  default     = ["dc1"]
}

variable "region" {
  description = "The region where the job should be placed."
  type        = string
  default     = "global"
}

variable "version_tag" {
  description = "The docker image version. For options, see https://hub.docker.com/r/prom/alertmanager"
  type        = string
  default     = "v0.23.0"
}

variable "resources" {
  description = "The resource to assign to the alertmanager service task."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 200,
    memory = 256
  }
}

variable "alertmanager_task_services" {
  description = "Configuration options of the alertmanager services and checks."
  type        = list(object({
    service_port_label = string
    service_name       = string
    service_tags       = list(string)
    check_enabled      = bool
    check_path         = string
    check_interval     = string
    check_timeout      = string
    connect_enabled    = bool
  }))
  default = [{
    service_port_label = "http",
    service_name       = "alertmanager",
    service_tags       = [],
    check_enabled      = true,
    check_path         = "/-/healthy",
    check_interval     = "3s",
    check_timeout      = "1s",
    connect_enabled    = true,
  }]
}

variable "alertmanager_yaml" {
  description = "The alertmanager configuration to pass to the task."
  type        = string
  // defaults as used in the upstream getting started tutorial.
  default     = <<EOF
route:
  group_by: ['alertname']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 1h
  receiver: 'web.hook'
receivers:
- name: 'web.hook'
  webhook_configs:
  - url: 'http://127.0.0.1:5001/'
inhibit_rules:
  - source_match:
      severity: 'critical'
    target_match:
      severity: 'warning'
    equal: ['alertname', 'dev', 'instance']
EOF
}

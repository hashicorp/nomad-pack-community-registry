variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name."
  type        = string
  // If "", the pack name will be used
  default = ""
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
  default     = "latest"
}

variable "http_port" {
  description = "The Nomad client port that routes to the alertmanager."
  type        = number
  default     = 9093
}

variable "cluster_port" {
  description = "The Nomad client port that routes to the alertmanager."
  type        = number
  default     = 9094
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

variable "register_consul_service" {
  description = "If you want to register a consul service for the job"
  type        = bool
  default     = true
}

variable "register_consul_connect_enabled" {
  description = "If you want to run the consul service with connect enabled. This will only work with register_consul_service = true"
  type        = bool
  default     = true
}

variable "consul_service_name" {
  description = "The consul service name for the hello-world application"
  type        = string
  default     = "alertmanager"
}

variable "consul_service_tags" {
  description = "The consul service name for the hello-world application"
  type        = list(string)
  // defaults to integrate with Fabio or Traefik
  // This routes at the root path "/", to route to this service from
  // another path, change "urlprefix-/" to "urlprefix-/<PATH>" and
  // "traefik.http.routers.http.rule=Path(`/`)" to
  // "traefik.http.routers.http.rule=Path(`/<PATH>`)"
  default = [
    "urlprefix-/",
    "traefik.enable=true",
    "traefik.http.routers.http.rule=Path(`/`)",
  ]
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

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
  default     = [
    {
      attribute = "$${attr.kernel.name}",
      value     = "linux",
      operator  = "",
    },
  ]
}

variable "node_exporter_group_network" {
  description = "The node exporter network configuration options."
  type        = object({
    mode  = string
    ports = map(number)
  })
  default = {
    mode  = "bridge",
    ports = {
      "http" = 9100,
    },
  }
}

variable "node_exporter_task_config" {
  description = "The node exporter task config options."
  type        = object({
    version = string
  })
  default     = {
    version = "v1.2.2",
  }
}

variable "node_exporter_task_resources" {
  description = "The resource to assign to the node exporter task."
  type        = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 100,
    memory = 128,
  }
}

variable "node_exporter_task_services" {
  description = "Configuration options of the node exporter services and checks."
  type        = list(object({
    service_port_label = string
    service_name       = string
    service_tags       = list(string)
    check_enabled      = bool
    check_type         = string
    check_interval     = string
    check_timeout      = string
  }))
  default = [{
    service_port_label = "http",
    service_name       = "prometheus-node-exporter",
    service_tags       = [],
    check_enabled      = true,
    check_type         = "tcp"
    check_interval     = "3s",
    check_timeout      = "1s",
  }]
}

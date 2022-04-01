variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name."
  type        = string
  default     = ""
}


variable "namespace" {
  description = "The namespace where the job should be placed."
  type        = string
  default     = "default"
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
  description = "The docker image version. For options, see https://hub.docker.com/_/redis?tab=tags"
  type        = string
  default     = "latest"
}

variable "constraints" {
  description = "Constraints to apply to the entire job."
  type = list(object({
    attribute = string
    operator  = string
    value     = string
  }))
  default = []
}

variable "server_count" {
  description = "The number of Redis server instances to create."
  type		= number
  default = 1
}

variable "redis_group_name" {
  description = "Optionally apply a custom name for the redis task group."
  type        = string
  default     = "server"
}

variable "redis_group_network" {
  description = "The redis network configuration options."
  type = object({
    mode  = string
    ports = map(number)
  })
  default = {
    mode = "bridged"
    ports = {
      "http" = 6379,
    },
  }
}

variable "redis_group_services" {
  description = "Configuration options of the redis services and checks."
  type = list(object({
    service_port_label = string
    service_name       = string
    service_tags       = list(string)
    check_enabled      = bool
    check_path         = string
    check_interval     = string
    check_timeout      = string
    upstreams = list(object({
      name = string
      port = number
    }))
  }))
  default = [{
    service_port_label = "http",
    service_name       = "redis",
    service_tags       = [],
    upstreams          = [],
    check_enabled      = true,
    check_path         = "/ready",
    check_interval     = "3s",
    check_timeout      = "1s",
  }]
}

variable "redis_task_args" {
  description = "Optionally provide custom arguments to the redis task."
  type    = list(string)
  default = []
}

variable "resources" {
  description = "The resource to assign to the redis service task."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 200,
    memory = 256
  }
}
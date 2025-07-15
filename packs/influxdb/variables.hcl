# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name."
  type        = string
  // If "", the pack name will be used
  default = "influxdb"
}

variable "region" {
  description = "The region where jobs will be deployed."
  type        = string
  default     = ""
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement."
  type        = list(string)
  default     = ["dc1"]
}

variable "node_pool" {
  description = "The node pool where the job should be placed."
  type        = string
  default     = "default"
}

variable "namespace" {
  description = "The namespace where the job should be placed."
  type        = string
  default     = ""
}

variable "constraints" {
  description = "Constraints to apply to the entire job."
  type = list(object({
    attribute = string
    operator  = string
    value     = string
  }))
  default = [
    {
      attribute = "$${attr.kernel.name}",
      value     = "(linux|darwin)",
      operator  = "regexp",
    },
  ]
}

variable "image_name" {
  description = "The docker image name."
  type        = string
  default     = "influxdb"
}

variable "image_tag" {
  description = "The docker image tag."
  type        = string
  default     = "2.0.9"
}

variable "task_resources" {
  description = "Resources used by InfluxDB task."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 500,
    memory = 256,
  }
}

variable "register_consul_service" {
  description = "If you want to register a consul service for the job."
  type        = bool
  default     = false
}

variable "consul_service_name" {
  description = "The consul service name for the application."
  type        = string
  default     = "influxdb"
}

variable "consul_service_tags" {
  description = "The consul service name for the application."
  type        = list(string)
  default     = []
}

variable "data_volume_name" {
  description = "The name of the dedicated data volume you want InfluxDB to use."
  type        = string
  default     = ""
}

variable "data_volume_type" {
  description = "The type of the dedicated data volume you want InfluxDB to use."
  type        = string
  default     = "host"
}

variable "config_volume_name" {
  description = "The name of the dedicated config volume you want InfluxDB to use."
  type        = string
  default     = ""
}

variable "config_volume_type" {
  description = "The type of the dedicated config volume you want InfluxDB to use."
  type        = string
  default     = "host"
}

variable "docker_influxdb_env_vars" {
  type        = map(string)
  description = "Environment variables to pass to Docker container."
  default     = {}
}

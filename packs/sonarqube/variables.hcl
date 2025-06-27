# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name."
  type        = string
  default     = "sonarqube"
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

variable "namespace" {
  description = "The namespace where the job should be placed."
  type        = string
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
  default     = "sonarqube"
}

variable "image_tag" {
  description = "The docker image tag."
  type        = string
  default     = "lts-community"
}

variable "task_resources" {
  description = "Resources used by sonarqube task."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 1000,
    memory = 2048,
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
  default     = "sonarqube"
}

variable "consul_service_tags" {
  description = "The consul service name for the application."
  type        = list(string)
  default     = []
}

variable "volume_name" {
  description = "The name of the volume you want sonarqube to use."
  type        = string
}

variable "volume_type" {
  description = "The type of the volume you want sonarqube to use."
  type        = string
  default     = "host"
}

variable "sonarqube_env_vars" {
  type        = map(string)
  description = "Environment variables to pass to Docker container."
  default     = {}
}

# Copyright IBM Corp. 2021, 2025
# SPDX-License-Identifier: MPL-2.0

variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name"
  type        = string
  // If "", the pack name will be used
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

variable "version_tag" {
  description = "The docker image version. For options, see https://hub.docker.com/r/jaegertracing/all-in-one"
  type        = string
  default     = "latest"
}

variable "http_ui_port" {
  description = "The Nomad client port that routes to the Jaeger"
  type        = number
  default     = 16686
}

variable "http_collector_port" {
  description = "The Nomad client port that routes to the Jaeger"
  type        = number
  default     = 14250
}

variable "resources" {
  description = "The resource to assign to the Jaeger service task"
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 200,
    memory = 512
  }
}

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

variable "consul_service_name" {
  description = "The consul service you wish to load balance"
  type        = string
  default     = "webapp"
}

variable "version_tag" {
  description = "The docker image version. For options, see https://hub.docker.com/_/nginx"
  type        = string
  default     = "1.21"
}

variable "http_port" {
  description = "The Nomad client port that routes to the Nginx. This port will be where you visit your load balanced application"
  type        = number
  default     = 8082
}

variable "resources" {
  description = "The resource to assign to the Nginx system task that runs on every client"
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 200,
    memory = 256
  }
}

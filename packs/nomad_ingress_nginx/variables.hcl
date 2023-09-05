# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Job variables.
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

variable "job_name" {
  description = "The name to use as the job name. Defaults to the pack name."
  type        = string
  // If "", the pack name will be used
  default = ""
}

variable "job_type" {
  description = "The scheduler type to use for the job."
  type        = string
  default     = "system"
}

variable "namespace" {
  description = "The namespace where the job will be placed"
  type        = string
  default     = "default"
}

variable "region" {
  description = "The region where the job will be placed."
  type        = string
  default     = "global"
}

# Nginx ingress variables.
variable "http_port" {
  description = "The Nomad client port that routes to the Nginx ingress."
  type        = number
  default     = 80
}

variable "http_port_host_network" {
  description = "The Nomad client host network where the `http_port` will be allocated."
  type        = string
  default     = ""
}

variable "nginx_count" {
  description = "The number of instances of the Nginx ingress to run. Only used if `job_type` is `service`."
  type        = number
  default     = 1
}

variable "nginx_extra_ports" {
  description = "List of additional ports to assign to the Nginx ingress."
  type = list(object({
    name         = string
    port         = number
    host_network = string
  }))
  default = []
}

variable "nginx_image" {
  description = "The Docker image to use for the Nginx ingress."
  type        = string
  default     = "nginx:1.21"
}

variable "nginx_resources" {
  description = "The resource to assign to the Nginx ingress task."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 200,
    memory = 256
  }
}

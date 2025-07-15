# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name"
  type        = string
  default     = "backstage"
}

variable "region" {
  description = "The region where jobs will be deployed"
  type        = string
  default     = ""
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

// PostgreSQL variables
variable "postgresql_group_nomad_service_name" {
  description = "The nomad service name for the PostgreSQL application."
  type        = string
  default     = "postgresql"
}

variable "postgresql_task_image" {
  description = "PostgreSQL's Docker image."
  type        = string
  default     = "postgres:13.2-alpine"
}

variable "postgresql_task_volume_path" {
  description = "The volume's absolute path in the host to be used by PostgreSQL."
  type        = string
  default     = "/var/lib/backstage/postgresql"
}

variable "postgresql_task_resources" {
  description = "The resources to assign to the PostgreSQL service."

  type = object({
    cpu    = number
    memory = number
  })

  default = {
    cpu    = 1024,
    memory = 1024
  }
}

// Backstage variables
variable "backstage_group_nomad_service_name" {
  description = "The nomad service name for the Backstage application."
  type        = string
  default     = "backstage"
}

variable "backstage_task_image" {
  description = "Backstage's Docker image."
  type        = string
  default     = "ghcr.io/backstage/backstage:1.7.1"
}

variable "backstage_task_nomad_vars" {
  description = "Backstage's nomad variables."

  type = list(object({
    key   = string
    value = string
  }))

  default = [
    {
    key   = "GITHUB_TOKEN"
    value = "github_token"
    }
  ]
}

variable "backstage_task_resources" {
  description = "The resources to assign to the Backstage service."

  type = object({
    cpu    = number
    memory = number
  })

  default = {
    cpu    = 512,
    memory = 256
  }
}

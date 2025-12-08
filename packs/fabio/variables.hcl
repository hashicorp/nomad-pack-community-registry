# Copyright IBM Corp. 2021, 2025
# SPDX-License-Identifier: MPL-2.0

variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name."
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
  default = [
    {
      attribute = "$${attr.kernel.name}",
      value     = "linux",
      operator  = "",
    },
  ]
}

variable "fabio_group_network" {
  description = "The Fabio group network configuration options."
  type        = object({
    mode  = string
    ports = map(number)
  })
  default = {
    mode  = "bridge",
    ports = {
      "http" = 9999,
      "ui"   = 9998,
    },
  }
}

variable "fabio_task_config" {
  description = "Configuration options to use for the Fabio task driver config."
  type        = object({
    version = string
  })
  default     = {
    version = "1.5.15-go1.15.5",
  }
}

variable "fabio_task_app_properties" {
  description = "The contents of a Fabio properties file to pass to the Fabio app."
  type        = string
  default     = ""
}

variable "fabio_task_resources" {
  description = "The resource to assign to the Fabio task."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 200,
    memory = 256
  }
}

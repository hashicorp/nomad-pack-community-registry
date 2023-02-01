# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

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
      attribute = "$${attr.kernel.name}"
      value     = "linux"
      operator  = ""
    },
  ]
}

variable "job_type" {
  description = "The type of the job."
  type        = string
  default     = "service"
}

variable "instance_count" {
  description = "In case the job is ran as a service, how many copies of the snmp_exporter group to run."
  type        = number
  default     = 1
}
variable "snmp_exporter_group_network" {
  description = "The SNMP exporter network configuration options."
  type        = object({
    mode  = string
    ports = map(number)
  })
  default = {
    mode  = "bridge"
    ports = {
      "http" = 9116
    }
  }
}

variable "snmp_exporter_task_config" {
  description = "The SNMP exporter task config options."
  type        = object({
    image   = string
    version = string
  })
  default     = {
    image   = "prom/snmp-exporter"
    version = "v0.20.0"
  }
}

variable "snmp_exporter_task_resources" {
  description = "The resource to assign to the SNMP exporter task."
  type        = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 100
    memory = 64
  }
}

variable "snmp_exporter_task_services" {
  description = "Configuration options of the SNMP exporter services and checks."
  type        = list(object({
    service_port_label = string
    service_name       = string
    service_tags       = list(string)
    check_enabled      = bool
    check_type         = string
    check_path         = string
    check_interval     = string
    check_timeout      = string
  }))
  default = [{
    service_port_label = "http"
    service_name       = "prometheus-snmp-exporter"
    service_tags       = []
    check_enabled      = true
    check_type         = "tcp"
    check_path         = "/"
    check_interval     = "30s"
    check_timeout      = "30s"
  }]
}

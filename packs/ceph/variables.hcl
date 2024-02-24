# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "job_name" {
  description = "The name of the Ceph job."
  type        = string
  default     = "ceph"
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
  description = "The namespace for the job."
  type        = string
  default     = "default"
}

variable "ceph_image" {
  description = "The container image for Ceph."
  type        = string
  default     = "ceph/daemon:latest-octopus"
}

variable "ceph_cluster_id" {
  description = "The Ceph cluster ID (will default to a random UUID)."
  type        = string
  default     = ""
}

variable "ceph_demo_uid" {
  description = "The UID for the Ceph demo."
  type        = string
  default     = "demo"
}

variable "ceph_demo_bucket" {
  description = "The bucket name for the Ceph demo."
  type        = string
  default     = "example"
}

variable "ceph_monitor_service_name" {
  description = "The Consul service name for the Ceph monitoring service."
  type        = string
  default     = "ceph-mon"
}

variable "ceph_monitor_port" {
  description = "The port for the Ceph monitoring service to listen on."
  type        = number
  default     = 3300
}

variable "ceph_dashboard_service_name" {
  description = "The Consul service name for the Ceph dashboard service."
  type        = string
  default     = "ceph-dashboard"
}

variable "ceph_dashboard_port" {
  description = "The port for the Ceph dashboard to listen on."
  type        = number
  default     = 5000
}

variable "ceph_config_file" {
  description = "The full text of the Ceph demo configuration file. A reasonable demo will be provided by default."
  type        = string
  default     = ""
}

variable "constraints" {
  description = "Additional constraints to apply to the job."
  type = list(object({
    attribute = string
    operator  = string
    value     = string
  }))
  default = []
}

variable "resources" {
  description = "The resources to assign to the task."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 256,
    memory = 600 # ceph is hungry!
  }
}

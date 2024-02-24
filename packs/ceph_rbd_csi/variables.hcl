# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "job_name" {
  description = "The prefix to use as the job name for the plugins (ex. ceph_rbd_controller for the controller)."
  type        = string
  default     = "ceph_rbd"
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

variable "plugin_id" {
  description = "The ID to register in Nomad for the plugin."
  type        = string
  default     = "rbd.csi.ceph.com"
}

variable "plugin_namespace" {
  description = "The namespace for the plugin job."
  type        = string
  default     = "default"
}

# note: there's no "latest" published for this image
variable "plugin_image" {
  description = "The container image for the plugin."
  type        = string
  default     = "quay.io/cephcsi/cephcsi:canary"
}

variable "controller_count" {
  description = "The number of controller instances to be deployed (at least 2 recommended)."
  type        = number
  default     = 2
}

variable "constraints" {
  description = "Additional constraints to apply to the jobs."
  type = list(object({
    attribute = string
    operator  = string
    value     = string
  }))
  default = []
}

variable "resources" {
  description = "The resources to assign to the plugin tasks."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 256,
    memory = 256
  }
}

variable "ceph_cluster_id" {
  description = "The Ceph cluster ID (required)."
  type        = string
  default     = ""
}

variable "ceph_monitor_service_name" {
  description = "The Consul service name for the Ceph monitoring service."
  type        = string
  default     = "ceph-mon"
}

variable "prometheus_service_name" {
  description = "The Consul service name for prometheus monitoring."
  type        = string
  default     = "prometheus"
}

variable "prometheus_service_tags" {
  description = "The Consul service tags for prometheus monitoring."
  type        = list(string)
  default     = ["ceph-csi"]
}

variable "volume_id" {
  description = "ID for the example volume spec to output."
  type        = string
  default     = "myvolume"
}

variable "volume_namespace" {
  description = "Namespace for the example volume spec to output."
  type        = string
  default     = "default"
}

variable "volume_min_capacity" {
  description = "Minimum capacity for the example volume spec to output."
  type        = string
  default     = "10GiB"
}

variable "volume_max_capacity" {
  description = "Maximum capacity for the example volume spec to output."
  type        = string
  default     = "30GiB"
}

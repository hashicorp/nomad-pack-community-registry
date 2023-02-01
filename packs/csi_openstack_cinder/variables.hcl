# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name"
  type        = string
  default     = ""
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement"
  type        = list(string)
  default     = ["dc1"]
}

variable "region" {
  description = "The region where the job should be placed"
  type        = string
  default     = "global"
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
      attribute = "$${attr.platform.aws.placement.availability-zone}",
      value     = "nova",
      operator  = "",
    },
  ]
}

variable "job_restart_config" {
  type = object({
    attempts = number
    delay    = string
    mode     = string
    interval = string
  })
  default = {
    attempts = 5
    delay    = "15s"
    mode     = "delay"
    interval = "5m"
  }
}

variable "cloud_conf_file" {
  description = "[REQUIRED] Path to custom cloud.conf file to be mounted to the CSI containers. For reference, see https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/openstack-cloud-controller-manager/using-openstack-cloud-controller-manager.md#global"
  type        = string
}

variable "csi_plugin_id" {
  description = "The ID to register the CSI plugin with."
  type        = string
  default     = "csi-cinder"
}

variable "version_tag" {
  description = "The docker image version. For options, see https://github.com/kubernetes/cloud-provider-openstack/releases"
  type        = string
  default     = "latest"
}

variable "cinder_log_level" {
  description = "The log level to run the csi driver at. Valid values 1 through 5"
  type        = string
  default     = "3"
}

variable "vault_config" {
  description = "Nomad Job Vault Configuration. Set `enabled = true` to configure the job to use vault See: https://www.nomadproject.io/docs/job-specification/vault"
  type = object({
    enabled       = bool
    policies      = list(string)
    change_mode   = string
    change_signal = string
    env           = bool
    namespace     = string
  })
  default = {
    enabled       = false
    policies      = []
    change_mode   = "restart"
    change_signal = ""
    env           = true
    namespace     = ""
  }
}

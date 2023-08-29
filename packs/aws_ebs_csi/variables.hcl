# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "job_name" {
  description = "The prefix to use as the job name for the plugins (ex. aws_ebs_controller for the controller)."
  type        = string
  default     = "aws_ebs"
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement."
  type        = list(string)
  default     = ["dc1"]
}

variable "region" {
  description = "The region where the job should be placed."
  type        = string
  default     = "global"
}

variable "plugin_id" {
  description = "The ID to register in Nomad for the plugin."
  type        = string
  default     = "ebs.csi.aws.com"
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
  default     = "public.ecr.aws/ebs-csi-driver/aws-ebs-csi-driver:v1.5.1"
}

variable "plugin_log_level" {
  description = "The log level for the plugin."
  type        = string
  default     = "debug"
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

variable "availability_zones" {
  description = "AWS availability zones for the node plugins and example volume output."
  type        = list(string)
  default     = ["us-east-1b"]
}

variable "resources" {
  description = "The resources to assign to the plugin tasks."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 500,
    memory = 256
  }
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

variable "volume_type" {
  description = "AWS EBS volume type."
  type        = string
  default     = "gp2"
}

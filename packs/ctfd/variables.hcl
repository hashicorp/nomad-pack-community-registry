# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name."
  type        = string
  // If "", the pack name will be used
  default = "ctfd"
}

variable "region" {
  description = "The region where jobs will be deployed."
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

variable "namespace" {
  description = "The namespace where the job should be placed."
  type        = string
}

variable "register_consul_service" {
  description = "If you want to register a Consul service for the job."
  type        = bool
  default     = false
}

variable "consul_service_name" {
  description = "The consul service name for the application."
  type        = string
  default     = "ctfd"
}

variable "consul_service_tags" {
  description = "The consul service tags for the application."
  type        = list(string)
  default     = ["ctfd"]
}

variable "uploads_volume_name" {
  description = "The name of the dedicated data volume you want CTFd to store file uploads into."
  type        = string
  default     = "ctfd_uploads"
}

variable "uploads_volume_type" {
  description = "The type of the dedicated data volume you want CTFd to store file uploads into."
  type        = string
  default     = "host"
}

variable "mariadb_volume_name" {
  description = "The name of the dedicated data volume you want MariaDB to store data into."
  type        = string
  default     = "ctfd_mariadb"
}

variable "mariadb_volume_type" {
  description = "The type of the dedicated data volume you want MariaDB to store data into."
  type        = string
  default     = "host"
}

variable "redis_volume_name" {
  description = "The name of the dedicated data volume you want Redis to store data into."
  type        = string
  default     = "ctfd_redis"
}

variable "redis_volume_type" {
  description = "The type of the dedicated data volume you want Redis to store data into."
  type        = string
  default     = "host"
}

variable "ctfd_resources" {
  description = "The resources reserved for CTFd itself."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 250,
    memory = 500,
  }
}

variable "ctfd_image_name" {
  description = "The CTFd Docker image name to pull."
  type        = string
  default     = "ctfd/ctfd"
}

variable "ctfd_image_tag" {
  description = "The CTFd Docker image tag to pull."
  type        = string
  default     = "3.3.1-release"
}

variable "ctfd_port" {
  description = "The static host port that CTFd will be served on. If not specified, an external reverse proxy will be needed."
  type        = number
}

variable "ctfd_expect_reverse_proxy" {
  description = "If you want CTFd to expect being behind a reverse proxy."
  type        = bool
  default     = false
}

variable "mariadb_resources" {
  description = "The resources reserved for MariaDB."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 250,
    memory = 500,
  }
}

variable "mariadb_image_name" {
  description = "The MariaDB Docker image name to pull."
  type        = string
  default     = "mariadb"
}

variable "mariadb_image_tag" {
  description = "The MariaDB Docker image tag to pull."
  type        = string
  default     = "10"
}

variable "mariadb_root_password" {
  description = "The password that will be used for the 'root' MariaDB user."
  type        = string
  default     = "ctfd"
}

variable "mariadb_ctfd_password" {
  description = "The password that will be used to create the 'ctfd' MariaDB user."
  type        = string
  default     = "ctfd"
}

variable "redis_resources" {
  description = "The resources reserved for Redis."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 250,
    memory = 500,
  }
}

variable "redis_image_name" {
  description = "The Redis Docker image name to pull."
  type        = string
  default     = "redis"
}

variable "redis_image_tag" {
  description = "The Redis Docker image tag to pull."
  type        = string
  default     = "6"
}

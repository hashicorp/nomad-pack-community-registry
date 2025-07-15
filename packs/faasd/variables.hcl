# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name."
  type        = string
  // If "", the pack name will be used
  default = "faasd"
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

variable "namespace" {
  description = "The namespace where the job should be placed."
  type        = string
  default     = ""
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
      attribute = "$${attr.kernel.name}",
      value     = "linux",
      operator  = "regexp",
    },
  ]
}

variable "nats_image_name" {
  description = "The nats docker image name."
  type        = string
  default     = "docker.io/library/nats-streaming"
}

variable "auth_plugin_image_name" {
  description = "The faasd basic auth docker image name."
  type        = string
  default     = "ghcr.io/openfaas/basic-auth"
}

variable "gateway_image_name" {
  description = "The gateway docker image name."
  type        = string
  default     = "ghcr.io/openfaas/gateway"
}

variable "queue_worker_image_name" {
  description = "The faas queue worker docker image name."
  type        = string
  default     = "ghcr.io/openfaas/queue-worker"
}

variable "faasd_version" {
  type    = string
  default = "0.14.3"
}

variable "nats_image_tag" {
  type    = string
  default = "0.22.0"
}

variable "auth_plugin_image_tag" {
  type    = string
  default = "0.21.0"
}

variable "gateway_image_tag" {
  type    = string
  default = "0.21.0"
}

variable "queue_worker_image_tag" {
  type    = string
  default = "0.12.2"
}

variable "faasd_provider_task_resources" {
  description = "Resources used by faasd_provider task."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 50,
    memory = 100,
  }
}

variable "nats_task_resources" {
  description = "Resources used by nats task."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 50,
    memory = 50,
  }
}

variable "basic_auth_task_resources" {
  description = "Resources used by basic authentication task."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 20,
    memory = 30,
  }
}

variable "gateway_task_resources" {
  description = "Resources used by gateway task."

  type = object({
    cpu    = number
    memory = number
  })

  default = {
    cpu    = 50,
    memory = 50,
  }
}

variable "queue_worker_task_resources" {
  description = "Resources used by queue worker task."

  type = object({
    cpu    = number
    memory = number
  })

  default = {
    cpu    = 50,
    memory = 50,
  }
}

variable "register_auth_consul_service" {
  description = "If you want to register a consul service for the basic authentication task."
  type        = bool
  default     = false
}

variable "register_nats_consul_service" {
  description = "If you want to register a consul service for the nats task."
  type        = bool
  default     = false
}

variable "register_gateway_consul_service" {
  description = "If you want to register a consul service for the gateway task."
  type        = bool
  default     = false
}

variable "register_provider_consul_service" {
  description = "If you want to register a consul service for the provider task."
  type        = bool
  default     = false
}

variable "auth_consul_service_name" {
  description = "The consul service name for the basic authentication task."
  type        = string
  default     = "faasd-auth"
}

variable "provider_consul_service_name" {
  description = "The consul service name for the provider task."
  type        = string
  default     = "faasd-provider"
}

variable "nats_consul_service_name" {
  description = "The consul service name for the nats task."
  type        = string
  default     = "faasd-nats"
}

variable "gateway_consul_service_name" {
  description = "The consul service name for the gateway task."
  type        = string
  default     = "faasd-gateway"
}

variable "consul_service_tags" {
  description = "The consul service name for the application."
  type        = list(string)
  default     = []
}

variable "dns_servers" {
  description = "The dns server(s) you want faasd service resolve names to"
  type        = list(string)
  default     = []
}

variable "basic_auth_user" {
  description = "Username for Faasd gateway authentication"
  type = string
  default = "admin"
}

variable "basic_auth_password" {
  description = "Password for Faasd gateway authentication"
  type = string
  default = "password"
}

variable "docker_faasd_env_vars" {
  type        = map(string)
  description = "Environment variables to pass to Docker container."
  default     = {}
}



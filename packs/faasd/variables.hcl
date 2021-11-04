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
      value     = "(linux|darwin)",
      operator  = "regexp",
    },
  ]
}

variable "nats_image_name" {
  description = "The nats docker image name."
  type        = string
  default     = "docker.io/library/nats-streaming"
}

variable "basic_auth_image_name" {
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

variable "faasd_image_tag" {
  type    = string
  default = "0.13.0"
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
variable "register_monitoring_consul_service" {
  description = "If you want to register a consul service for the monitoring task."
  type        = bool
  default     = false
}
variable "register_provider_consul_service" {
  description = "If you want to register a consul service for the provider task."
  type        = bool
  default     = false
}

variable "basic_auth_consul_service_name" {
  description = "The consul service name for the basic authentication task."
  type        = string
  default     = "basic-auth"
}

variable "provider_consul_service_name" {
  description = "The consul service name for the provider task."
  type        = string
  default     = "faasd-provider"
}

variable "nats_consul_service_name" {
  description = "The consul service name for the nats task."
  type        = string
  default     = "nats"
}

variable "gateway_consul_service_name" {
  description = "The consul service name for the gateway task."
  type        = string
  default     = "gateway"
}

variable "faasd_monitoring_consul_service_name" {
  description = "The consul service name for the monitoring task."
  type        = string
  default     = "faasd-monitoring"
}

variable "volume_name" {
  description = "The name of the volume you want faasd to use."
  type        = string
}

variable "volume_type" {
  description = "The type of the volume you want faasd to use."
  type        = string
  default     = "host"
}

variable "docker_faasd_env_vars" {
  type        = map(string)
  description = "Environment variables to pass to Docker container."
  default     = {}
}



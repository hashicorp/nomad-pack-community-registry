variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name."
  type        = string
  // If "", the pack name will be used
  default = "jenkins"
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

variable "image_name" {
  description = "The docker image name."
  type        = string
  default     = "jenkins/jenkins"
}

variable "image_tag" {
  description = "The docker image tag."
  type        = string
  default     = "2.318"
}

variable "jenkins_task_resources" {
  description = "Resources used by jenkins task."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 1000,
    memory = 1024,
  }
}

variable "register_consul_service" {
  description = "If you want to register a consul service for the job."
  type        = bool
  default     = false
}

variable "consul_service_name" {
  description = "The consul service name for the application."
  type        = string
  default     = "jenkins"
}

variable "consul_service_tags" {
  description = "The consul service name for the application."
  type        = list(string)
  default     = []
}

variable "jenkins_volume" {
  description = "The name of the volume you want Jenkins to use."
  type        = string
}

variable "docker_jenkins_env_vars" {
  type        = map(string)
  description = "Environment variables to pass to Docker container."
  default     = {}
}



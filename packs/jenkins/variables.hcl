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

variable "plugins" {
  description = "A list of jenkins plugins to install. See https://github.com/jenkinsci/docker/blob/master/README.md#plugin-installation-manager-cli-preview-1 for more info."
  type        = list(string)
}

variable "jasc_config" {
  description = "Use the Jenkins as Code plugin to configure jenkins. This requires the configuration-as-code plugin to be installed."
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
  default     = "lts-jdk11"
}

variable "task_resources" {
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
}

variable "volume_name" {
  description = "The name of the volume you want Jenkins to use."
  type        = string
}

variable "volume_type" {
  description = "The type of the volume you want Jenkins to use."
  type        = string
  default     = "host"
}

variable "docker_jenkins_env_vars" {
  type        = map(string)
  description = "Environment variables to pass to Docker container."
  default     = {}
}

variable "jenkins_vault" {
  description = "List of Vault Policies"
  type = list(string)
  default = null
  }

variable "jenkins_task_cacert" {
  description = "CA for using external SSL"
  type = string
  default = null
  }

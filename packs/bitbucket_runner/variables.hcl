variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name."
  type = string
  default = ""
}

variable "priority" {
  description = "The priority for the job."
  type = number
  default = 50
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement."
  type = list(string)
  default = ["dc1"]
}

variable "region" {
  description = "The region where the job should be placed."
  type = string
  default = "global"
}

variable "namespace" {
  description = "The namespace where the job should be placed."
  type = string
  default = "default"
}

variable "constraints" {
  description = "Constraints to apply to the entire job."
  type = list(object({
    attribute = string
    operator = string
    value = string
  }))
  default = [{
    attribute = "$${attr.kernel.name}",
    value = "linux",
    operator = "",
  }]
}

variable "network_mode" {
  description = "The network mode to use."
  type = string
  default = "bridge"
}

variable "task_resources" {
  description = "The resources to assign the task."
  type = object({
    cpu = number
    memory = number
    memory_max = number
  })
  default = {
    cpu = 200,
    memory = 256,
    memory_max = 768,
  }
}

variable "task_mounts" {
  description = "Mounts for the runner task."
  type = list(object({
    type = string
    target = string
    source = string
    readonly = bool
  }))
  default = [
    {
      type = "bind"
      target = "/var/run/docker.sock"
      source = "/var/run/docker.sock"
      readonly = false
    },
    {
      type = "bind"
      target = "/tmp"
      source = "/tmp"
      readonly = false
    },
    {
      type = "bind"
      target = "/var/lib/docker/containers"
      source = "/var/lib/docker/containers"
      readonly = true
    },
  ]
}

variable "task_environment" {
  description = "Environment variables for the bitbucket runner-task. Copy from BitBucket webpage when initializing runner."
  type = map(string)
  default = {}
}

variable "task_services" {
  description = "Configuration options of the Consul services and checks."
  type = list(object({
    service_port = number
    service_name = string
    service_tags = list(string)
    check_enabled = bool
    check_type = string
    check_path = string
    check_interval = string
    check_timeout = string
  }))
  default = []
}

variable "container_image" {
  description = "The container image used by the task."
  type = object({
    name = string
    version = string
  })
  default = {
    name = "docker-public.packages.atlassian.com/sox/atlassian/bitbucket-pipelines-runner",
    version = "latest",
  }
}

variable "instances" {
  description = "The number of instances to create."
  type = number
  default = 1
}

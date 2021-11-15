variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name."
  type        = string
  // If "", the pack name will be used
  default = ""
}

variable "constraints" {
  description = "Constraints to apply to the entire job."
  type        = list(object({
    attribute = string
    operator  = string
    value     = string
  }))
  default = [
    {
      attribute = "$${attr.kernel.name}",
      value     = "linux",
      operator  = "",
    },
  ]
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

variable "version_tag" {
  description = "The docker image version. For options, see https://hub.docker.com/grafana/loki"
  type        = string
  default     = "latest"
}

variable "http_port" {
  description = "The Nomad client port that routes to the Loki."
  type        = number
  default     = 3100
}

variable "grpc_port" {
  description = "The Nomad client port that routes to the Loki."
  type        = number
  default     = 9095
}

variable "resources" {
  description = "The resource to assign to the Loki service task."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 200,
    memory = 256
  }
}

variable "loki_yaml" {
  description = "The Loki configuration to pass to the task."
  type        = string
  default     = ""
}

variable "rules_yaml" {
  description = "The Loki rules to pass to the task."
  type        = string
  default     = ""
}

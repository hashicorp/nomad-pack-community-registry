variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name."
  type        = string
  // If "", the pack name will be used
  default = ""
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
  description = "The docker image version. For options, see https://hub.docker.com/grafana/grafana"
  type        = string
  default     = "8.2.0"
}

variable "http_port" {
  description = "The Nomad client port that routes to the Grafana."
  type        = number
  default     = 3000
}

variable "upstreams" {
  description = ""
  type = object({
    name = string
    port = number
  })
}

variable "resources" {
  description = "The resource to assign to the Grafana service task."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 200,
    memory = 256
  }
}

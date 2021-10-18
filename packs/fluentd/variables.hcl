variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name."
  type        = string
  // If "", the pack name will be used
  default     = ""
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

variable "service_name" {
  description = "The consul service you wish to load balance over."
  type        = string
  default     = "fluentd"
}

variable "version_tag" {
  description = "The docker image version. For options, see https://hub.docker.com/_/fluentd"
  type        = string
  default     = "v1.14-1"
}

variable "http_port" {
  description = "The Nomad client port that routes to Fluentd."
  type        = number
  default     = 24224
}

variable "resources" {
  description = "The resource to assign to the Fluentd service task that runs on every client."
  type = object({
    cpu    = number
    memory = number
    network_mbits = number
  })
  default = {
    cpu    = 200,
    memory = 128
    network_mbits = 10
  }
}

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
  description = "The docker image version."
  type        = string
  default     = "2.5"
}

variable "http_port" {
  description = "The Nomad client port that routes to the Traefik. This port will be where you visit your load balanced application."
  type        = number
  default     = 8080
}

variable "api_port" {
  description = "The port assigned to visit the Traefik API"
  type        = number
  default     = 1936
}

variable "consul_port" {
  description = "The consul HTTP port"
  type        = number

  default     = 8500
}

variable "resources" {
  description = "The resource to assign to the Traefik system task that runs on every client."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 200,
    memory = 128
  }
}

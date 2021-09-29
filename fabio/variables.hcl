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

variable "http_port" {
  description = "The Nomad client port that routes to the Fabio. This port will be where you visit your load balanced application."
  type        = number
  default     = 9999
}

variable "ui_port" {
  description = "The port assigned to visit the Fabio UI"
  type        = number
  default     = 9998
}

variable "resources" {
  description = "The resource to assign to the Fabio system task that runs on every client."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 200,
    memory = 128
  }
}

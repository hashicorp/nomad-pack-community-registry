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
  default     = "example-service-name"
}

variable "version" {
  description = "The haproxy docker image version. For options, see: https://hub.docker.com/_/haproxy"
  type        = string
  default     = "2.4"
}

variable "http_port" {
  description = "The Nomad client port that routes to the HAProxy. This port will be where you visit your load balanced application."
  type        = number
  default     = 8080
}

variable "ui_port" {
  description = "The port assigned to visit the HAProxy UI"
  type        = number
  default     = 1936
}

variable "consul_dns_port" {
  description = "The consul DNS port"
  type        = number

  default     = 8600
}

variable "pre_provisioned_slot_count" {
  description = "Backend slots to pre-provision"
  type        = number
  default     = 10
}

variable "resources" {
  description = "The resource to assign to the HAProxy system task that runs on every client."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 200,
    memory = 128
  }
}

variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name"
  type        = string
  // If "", the pack name will be used
  default = ""
}

variable "region" {
  description = "The region where jobs will be deployed"
  type        = string
  default     = ""
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement"
  type        = list(string)
  default     = ["dc1"]
}

variable "count" {
  description = "The number of app instances to deploy"
  type        = number
  default     = 1
}

variable "register_consul_service" {
  description = "If you want to register a consul service for the job"
  type        = bool
  default     = true
}

variable "ports" {
  description = ""
  type = list(object({
    name = string
    port = number
  }))
}

variable "env_vars" {
  description = ""
  type = list(object({
    key   = string
    value = string
  }))
}

variable "consul_service_name" {
  description = "The consul service name for the application"
  type        = string
  default     = "service"
}

variable "resources" {
  description = "The resource to assign to the Nginx system task that runs on every client"
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 200,
    memory = 256
  }
}

// variable "consul_service_tags" {
//   description = "The consul service name for the hello-world application"
//   type        = list(string)
//   // defaults to integrate with Fabio or Traefik
//   // This routes at the root path "/", to route to this service from
//   // another path, change "urlprefix-/" to "urlprefix-/<PATH>" and
//   // "traefik.http.routers.http.rule=Path(`/`)" to
//   // "traefik.http.routers.http.rule=Path(`/<PATH>`)"
//   default = [
//     "urlprefix-/",
//     "traefik.enable=true",
//     "traefik.http.routers.http.rule=Path(`/`)",
//   ]
// }

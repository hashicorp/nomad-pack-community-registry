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

variable "register_consul_service" {
  description = "If you want to register a consul service for the job"
  type        = bool
  default     = true
}

variable "consul_service_name" {
  description = "The consul service name for the hello-world application."
  type        = string
  default     = "hello-world-service"
}

variable "consul_service_tags" {
  description = "The consul service name for the hello-world application."
  type        = list(string)
  // defaults to integrat with Fabio or Traefik
  default     = [
    "urlprefix-/",
    "traefik.enable=true",
    "traefik.http.routers.http.rule=Path(`/myapp`)",
  ]
}

variable "docker_image" {
  description = "The docker image to deploy."
  type        = string
  default     = "httpd:latest"
}

variable "app_count" {
  description = "The number of app instances to deploy"
  type        = number
  default     = 2
}

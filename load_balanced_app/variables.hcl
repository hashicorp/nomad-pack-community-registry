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

variable "app_image" {
  description = "The docker image used as the load balanced app"
  type        = string
  default     = "httpd:latest"
}

variable "service_name" {
  description = "The name of the Consul service to assign to the app."
  type        = string
  default     = "load-balanced-app"
}

variable "app_count" {
  description = "The number of instances of the load balanced application"
  type        = number
  default     = 3
}

variable "app_http_port" {
  description = "The app's http port that should be exposed to the load balancer"
  type        = number
  default     = 80
}

variable "load_balancer_http_port" {
  description = "The Nomad client port that routes to the load balancer. This port will be where you visit your load balanced application."
  type        = number
  default     = 9999
}

variable "load_balancer_ui_port" {
  description = "The port assigned to visit the load balancer UI"
  type        = number
  default     = 9998
}

variable "app_resources" {
  description = "The resource to assign to the application being load balanced."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 500,
    memory = 256
  }
}

variable "lb_resources" {
  description = "The resource to assign to load balancer system task that runs on every client."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 200,
    memory = 128
  }
}

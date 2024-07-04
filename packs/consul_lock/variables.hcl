variable "job_name" {
  description = "The name of the job."
  type        = string
  default     = "example"
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

variable "namespace" {
  description = "The namespace for the job."
  type        = string
  default     = "default"
}

variable "locker_image" {
  description = "The container image for the lock task (needs curl)."
  type        = string
  default     = "alpine:latest"
}

variable "locker_script_path" {
  description = "The path to the locker script"
  type        = string
  default     = "./templates/script.sh"
}

variable "locker_key" {
  description = "The path to the locker script"
  type        = string
  default     = "leader"
}

variable "application_image" {
  description = "The container image for the main task."
  type        = string
  default     = "busybox:1"
}

variable "application_args" {
  description = "The command and args for the main task's application."
  type        = string
  default     = "httpd -v -f -p 8001 -h /local"
}

variable "application_port_name" {
  description = "The name of the port the application listens on."
  type        = string
  default     = "port"
}

variable "application_port" {
  description = "The port the application listens on."
  type        = string
  default     = 8001
}

variable "constraints" {
  description = "Additional constraints to apply to the jobs."
  type = list(object({
    attribute = string
    operator  = string
    value     = string
  }))
  default = []
}

variable "resources" {
  description = "The resources to assign to the main task."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 500,
    memory = 256
  }
}

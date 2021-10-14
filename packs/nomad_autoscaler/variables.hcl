variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name."
  type        = string
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

variable "namespace" {
  description = "The namespace where the job should be placed."
  type        = string
  default     = "default"
}

variable "autoscaler_agent_network" {
  description = "The Nomad Autoscaler network configuration options."
  type = object({
    autoscaler_http_port_label = string
  })
  default = {
    autoscaler_http_port_label = "http",
  }
}

variable "autoscaler_agent_task" {
  description = "Details configuration options for the Nomad Autoscaler agent task."
  type = object({
    driver               = string
    version              = string
    additional_cli_args  = list(string)
    config_files         = list(string)
    scaling_policy_files = list(string)
  })
  default = {
    driver               = "docker",
    version              = "0.3.3",
    additional_cli_args  = ["-nomad-address=http://$${attr.unique.network.ip-address}:4646", "-http-bind-address=0.0.0.0"],
    config_files         = [],
    scaling_policy_files = []
  }
}

variable "autoscaler_agent_task_resources" {
  description = "The resource to assign to the Nomad Autoscaler task."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 500,
    memory = 256
  }
}

variable "autoscaler_agent_task_service" {
  description = "Configuration options of the Nomad Autoscaler service and check."
  type = object({
    enabled        = bool
    service_name   = string
    service_tags   = list(string)
    check_interval = string
    check_timeout  = string
  })
  default = {
    enabled        = true
    service_name   = "nomad-autoscaler",
    service_tags   = [],
    check_interval = "3s",
    check_timeout  = "1s",
  }
}

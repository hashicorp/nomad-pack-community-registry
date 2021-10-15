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
  description = "Optional namespace for the job to reside in"
  type        = string
  default     = ""
}

variable "count" {
  description = "The number of agents to run"
  type        = number
  default     = 1
}

variable "resources" {
  description = "The resource to assign to the application."
  type = object({
    cpu    = number
    memory = number
   })
   default = {
     cpu    = 2048,
     memory = 2048,
   }
}

variable "tfc_address" {
  description = "The address of the Terraform Cloud installation"
  type        = string
  default     = "https://app.terraform.io"
}

variable "agent_token" {
  description = "The tfc-agent token generated in Terraform Cloud"
  type        = string
}

variable "agent_version" {
  description = "The version of the tfc-agent to run"
  type        = string
  default     = "latest"
}

variable "agent_name" {
  description = "Optional name of the agent to register"
  type        = string
  default     = ""
}

variable "agent_log_level" {
  description = "Granularity of logs to print. 'trace', 'debug', 'info', 'warn', and 'error' are accepted."
  type        = string
  default     = "info"
}

variable "agent_log_json" {
  description = "Generate logs in JSON format"
  type        = bool
  default     = false
}

variable "agent_auto_update" {
  description = "Automatically update agents while they are running. 'patch', 'minor', or 'disabled' are accepted."
  type        = string
  default     = "minor"
}

variable "agent_otlp_address" {
  description = "Optional host:port address of an OpenTelemetry gRPC listener"
  type        = string
  default     = ""
}

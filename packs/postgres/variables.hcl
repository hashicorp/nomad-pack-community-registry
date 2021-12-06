variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name"
  type        = string
  // If "", the pack name will be used
  default = ""
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement"
  type        = list(string)
  default     = ["dc1"]
}

variable "region" {
  description = "The region where the job should be placed"
  type        = string
  default     = "global"
}

variable "username" {
  description = "Initial admin username of Postgres"
  type        = string
  default     = "admin"
}

variable "password" {
  description = "Initial admin password of Postgres"
  type        = string
  default     = "password"
}
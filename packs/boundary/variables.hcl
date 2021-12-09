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

variable "controller_count" {
    description = "Number of Boundary Controller instances to deploy"
    type        = number
    default     = 3
}

variable "postgres_address" {
  description = "Address of Postgres database"
  type        = string
}

variable "postgres_username" {
  description = "Username with which to authenticate to Postgres"
  type        = string
}

variable "postgres_password" {
  description = "Password with which to authenticate to Postgres"
  type        = string
}

variable "docker_privileged" {
  description = "Run Boundary as a privileged Docker container"
  type        = bool
  default     = false
}

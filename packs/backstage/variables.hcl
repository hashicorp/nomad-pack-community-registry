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

// PostgreSQL variables
variable "postgresql_group_network" {
  description = ""
  type = list(object({
    name = string
    port = number
  }))

  default = [{
    name = "db"
    port = 5432
  }]
}

variable "postgresql_group_update" {
  description = "The PostgreSQL update configuration options."
  type        = object({
    min_healthy_time  = string
    healthy_deadline  = string
    progress_deadline = string
    auto_revert       = bool
  })
  default = {
    min_healthy_time  = "10s",
    healthy_deadline  = "5m",
    progress_deadline = "10m",
    auto_revert       = true,
  }
}

variable "postgresql_group_nomad_service_name" {
  description = "The nomad service name for the application."
  type        = string
  default     = "postgresql"
}

variable "postgresql_group_nomad_service_port" {
  description = "The nomad service port for the application."
  type        = string
  default     = "db"
}

variable "postgresql_group_restart_attempts" {
  description = "The number of times the task should restart on updates"
  type        = number
  default     = 2
}

variable "postgresql_task_image" {
  description = "PostgreSQL's Docker image."
  type        = string
  default     = "postgres:13.2-alpine"
}

variable "postgresql_task_volume_path" {
  description = "The volume's absolute path in the host to be used by PostgreSQL."
  type        = string
  default     = "/var/lib/backstage/postgresql"
}

variable "postgresql_task_env_vars" {
  description = "PostgreSQL's environment variables."
  type = list(object({
    key   = string
    value = string
  }))
  default = [
    {
      key   = "POSTGRES_USER"
      value = "backstage_user"
    },
    {
      key   = "POSTGRES_PASSWORD"
      value = "backstage_user_password"
    }
  ]
}

variable "postgresql_task_resources" {
  description = "The resources to assign to the PostgreSQL service."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 1024,
    memory = 1024
  }
}

variable "postgresql_data_folder_task_resources" {
  description = "The resources to assign to the PostgreSQL prestart task."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 20,
    memory = 20
  }
}

// Backstage variables
variable "backstage_group_network" {
  description = ""
  type = list(object({
    name = string
    port = number
  }))

  default = [{
    name = "http"
    port = 7007
  }]
}

variable "backstage_group_update" {
  description = "The Backstage update configuration options."
  type        = object({
    min_healthy_time  = string
    healthy_deadline  = string
    progress_deadline = string
    auto_revert       = bool
  })
  default = {
    min_healthy_time  = "10s",
    healthy_deadline  = "5m",
    progress_deadline = "10m",
    auto_revert       = true,
  }
}

variable "backstage_group_nomad_service_name" {
  description = "The consul service name for the application."
  type        = string
  default     = "backstage"
}

variable "backstage_group_nomad_service_port" {
  description = "The nomad service port for the application."
  type        = string
  default     = "http"
}

variable "backstage_group_restart_attempts" {
  description = "The number of times the task should restart on updates"
  type        = number
  default     = 2
}

variable "backstage_task_image" {
  description = "Backstage Docker image."
  type        = string
  default     = "ghcr.io/backstage/backstage:1.7.1"
}

variable "backstage_task_env_vars" {
  description = "Backstage environment variables."
  type = list(object({
    key   = string
    value = string
  }))
    default = [
    {
      key   = "POSTGRES_USER"
      value = "backstage_user"
    },
    {
      key   = "POSTGRES_PASSWORD"
      value = "backstage_user_password"
    },
    {
      key   = "GITHUB_TOKEN"
      value = "VG9rZW5Ub2tlblRva2VuVG9rZW5NYWxrb3ZpY2hUb2tlbg=="
    }
  ]
}

variable "backstage_task_resources" {
  description = "The resources to assign to the Backstage service."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 512,
    memory = 256
  }
}
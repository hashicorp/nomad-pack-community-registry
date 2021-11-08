// Job variables
variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name"
  type        = string
  // If "", the pack name will be used
  default = ""
}

variable "constraints" {
  description = "Constraints to apply to the entire job. Docker Volumes are required due to databases."
  type        = list(object({
    attribute = string
    operator  = string
    value     = string
  }))
  default = [
    {
      attribute = "$${attr.driver.docker.volumes.enabled}",
      value     = "true",
      operator  = "",
    },
  ]
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

variable "postgresql_group_consul_service_name" {
  description = "The consul service name for PostgreSQL."
  type        = string
  default     = "outline-postgresql"
}

variable "postgresql_group_consul_service_port" {
  description = "The consul service port for PostgreSQL."
  type        = string
  default     = "5432"
}

variable "postgresql_group_consul_tags" {
  description = ""
  type = list(string)
  default = [
    "database"
  ]
}

variable "postgresql_group_restart_attempts" {
  description = "The number of times the task should restart on updates"
  type        = number
  default     = 2
}

variable "postgresql_task_image" {
  description = "PostgreSQL's Docker image."
  type        = string
  default     = "bitnami/postgresql:13.4.0-debian-10-r77"
}

variable "postgresql_task_volume_path" {
  description = "The volume's absolute path in the host to be used by PostgreSQL."
  type        = string
  default     = "/var/lib/outline/postgresql"
}

variable "postgresql_task_env_vars" {
  description = "PostgreSQL's environment variables."
  type = list(object({
    key   = string
    value = string
  }))
  default = [
    {
      key   = "ALLOW_EMPTY_PASSWORD"
      value = "no"
    },
    {
      key   = "POSTGRESQL_USERNAME"
      value = "outline_user"
    },
    {
      key   = "POSTGRESQL_PASSWORD"
      value = "outline_user_password"
    },
    {
      key   = "POSTGRESQL_DATABASE"
      value = "outline"
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
    cpu    = 256,
    memory = 256
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

// MinIO variables
variable "minio_group_network" {
  description = ""
  type = list(object({
    name = string
    port = number
  }))

  default = [{
    name = "http"
    port = 9000
  }]
}

variable "minio_group_update" {
  description = "The MinIO update configuration options."
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

variable "minio_group_consul_service_name" {
  description = "The consul service name for MinIO."
  type        = string
  default     = "outline-minio"
}

variable "minio_group_consul_service_port" {
  description = "The consul service port for MinIO."
  type        = string
  default     = "http"
}

variable "minio_group_consul_tags" {
  description = ""
  type = list(string)
  default = [
    "database"
  ]
}

variable "minio_group_restart_attempts" {
  description = "The number of times the task should restart on updates"
  type        = number
  default     = 2
}

variable "minio_task_image" {
  description = "MinIO's Docker image."
  type        = string
  default     = "bitnami/minio:2021.10.27-debian-10-r2"
}

variable "minio_task_volume_path" {
  description = "The volume's absolute path in the host to be used by MinIO."
  type        = string
  default     = "/var/lib/outline/minio"
}

variable "minio_task_env_vars" {
  description = "MinIO's environment variables."
  type = list(object({
    key   = string
    value = string
  }))
  default = [
    {
      key   = "MINIO_ROOT_USER"
      value = "minio_root_user"
    },
    {
      key   = "MINIO_ROOT_PASSWORD"
      value = "minio_root_password"
    },
    {
      key   = "MINIO_BROWSER"
      value = "off"
    },
    {
      key   = "MINIO_DEFAULT_BUCKETS"
      value = "outline:none"
    },
    {
      key   = "MINIO_FORCE_NEW_KEYS"
      value = "yes"
    }
  ]
}

variable "minio_task_resources" {
  description = "The resources to assign to the MinIO service."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 256,
    memory = 256
  }
}

variable "minio_data_folder_task_resources" {
  description = "The resources to assign to the MinIO prestart task."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 20,
    memory = 20
  }
}

variable "minio_apply_policy_task_resources" {
  description = "The resources to assign to the MinIO poststart task."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 20,
    memory = 20
  }
}

// Redis variables
variable "redis_group_update" {
  description = "The Redis update configuration options."
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

variable "redis_group_consul_service_name" {
  description = "The consul service name for Redis."
  type        = string
  default     = "outline-redis"
}

variable "redis_group_consul_service_port" {
  description = "The consul service port for Redis."
  type        = string
  default     = "6379"
}

variable "redis_group_consul_tags" {
  description = ""
  type = list(string)
  default = [
    "database"
  ]
}

variable "redis_group_restart_attempts" {
  description = "The number of times the task should restart on updates."
  type        = number
  default     = 2
}

variable "redis_task_image" {
  description = "Redis's Docker image."
  type        = string
  default     = "bitnami/redis:6.2.6-debian-10-r24"
}

variable "redis_task_volume_path" {
  description = "The volume's absolute path in the host to be used by Redis."
  type        = string
  default     = "/var/lib/outline/redis"
}

variable "redis_task_env_vars" {
  description = "Redis' environment variables."
  type = list(object({
    key   = string
    value = string
  }))
  default = [
    {
      key   = "ALLOW_EMPTY_PASSWORD"
      value = "no"
    },
    {
      key   = "REDIS_PASSWORD"
      value = "redis_password"
    }
  ]
}

variable "redis_task_resources" {
  description = "The resources to assign to the Redis service."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 256,
    memory = 256
  }
}

variable "redis_data_folder_task_resources" {
  description = "The resources to assign to the Redis prestart task."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 20,
    memory = 20
  }
}

// Outline variables
variable "outline_group_network" {
  description = ""
  type = list(object({
    name = string
    port = number
  }))

  default = [{
    name = "http"
    port = 3000
  }]
}

variable "outline_group_update" {
  description = "The Outline update configuration options."
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

variable "outline_group_consul_service_name" {
  description = "The consul service name for the application."
  type        = string
  default     = "outline"
}

variable "outline_group_consul_service_port" {
  description = "The consul service port for the application."
  type        = string
  default     = "http"
}

variable "outline_group_consul_tags" {
  description = ""
  type = list(string)
  default = [
    "app"
  ]
}

variable "outline_group_upstreams" {
  description = "Consul Connect upstream configuration."
  type = list(object({
    name = string
    port = number
  }))
  default = [{
    name = "outline-postgresql"
    port = 5432
  },
  {
    name = "outline-minio"
    port = 9000
  },
  {
    name = "outline-redis"
    port = 6379
  }]
}

variable "outline_group_restart_attempts" {
  description = "The number of times the task should restart on updates"
  type        = number
  default     = 2
}

variable "outline_task_image" {
  description = "Outline Docker image."
  type        = string
  default     = "outlinewiki/outline:0.59.0"
}

variable "outline_task_env_vars" {
  description = "Outline environment variables."
  type = list(object({
    key   = string
    value = string
  }))
    default = [
    {
      key   = "SECRET_KEY"
      value = "d1434eff0725153e1cc457a013b53dbcdba6a2b40f00729be5680b56fc003897"
    },
    {
      key   = "UTILS_SECRET"
      value = "d5c59234b0018fe6036b0376d022c7f5187feb8cc1769c7bc4c282ed8a983b54"
    },
    {
      key   = "REDIS_URL"
      value = "redis://:redis_password@$${NOMAD_UPSTREAM_ADDR_outline-redis}"
    },
    {
      key   = "DATABASE_URL"
      value = "postgres://outline_user:outline_user_password@$${NOMAD_UPSTREAM_ADDR_outline-postgresql}/outline"
    },
    {
      key   = "DATABASE_URL_TEST"
      value = "postgres://outline_user:outline_user_password@$${NOMAD_UPSTREAM_ADDR_outline-postgresql}/outline_test"
    },
    {
      key   = "PGSSLMODE"
      value = "disable"
    },
    {
      key   = "URL"
      value = "http://localhost:3000"
    },
    {
      key   = "PORT"
      value = "3000"
    },
    {
      key   = "AWS_ACCESS_KEY_ID"
      value = "minio_root_user"
    },
    {
      key   = "AWS_SECRET_ACCESS_KEY"
      value = "minio_root_password"
    },
    {
      key   = "AWS_REGION"
      value = "us-east-1"
    },
    {
      key   = "AWS_S3_UPLOAD_BUCKET_URL"
      value = "http://localhost:9000"
    },
    {
      key   = "AWS_S3_UPLOAD_BUCKET_NAME"
      value = "outline"
    },
    {
      key   = "AWS_S3_UPLOAD_MAX_SIZE"
      value = "26214400"
    },
    {
      key   = "AWS_S3_FORCE_PATH_STYLE"
      value = "true"
    },
    {
      key   = "AWS_S3_ACL"
      value = "private"
    },
    {
      key   = "SLACK_KEY"
      value = "123123"
    },
    {
      key   = "SLACK_SECRET"
      value = "123123"
    },
    {
      key   = "FORCE_HTTPS"
      value = "false"
    },
    {
      key   = "ENABLE_UPDATES"
      value = "no"
    },
    {
      key   = "WEB_CONCURRENCY"
      value = "1"
    },
    {
      key   = "MAXIMUM_IMPORT_SIZE"
      value = "5120000"
    },
    {
      key   = "DEBUG"
      value = "http"
    },
    {
      key   = "DEFAULT_LANGUAGE"
      value = "en_US"
    }
  ]
}

variable "outline_task_resources" {
  description = "The resources to assign to the Outline service."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 512,
    memory = 256
  }
}
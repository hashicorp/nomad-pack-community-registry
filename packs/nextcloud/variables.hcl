# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name."
  type        = string
  default     = ""
}

variable "namespace" {
  description = "The namespace where the job should be placed."
  type        = string
  default     = "default"
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

variable "nextcloud_image_tag" {
  description = "The docker image tag. For options, see https://hub.docker.com/_/nextcloud"
  type        = string
  default     = "latest"
}

variable "postgres_image_tag" {
  description = "Tag for postgres image  For options, see https://hub.docker.com/_/postgres"
  type        = string
  default     = "9.6.14"
}

variable "constraints" {
  description = "Constraints to apply to the entire job."
  type = list(object({
    attribute = string
    operator  = string
    value     = string
  }))
  default = [
    {
      attribute = "$${attr.kernel.name}",
      operator  = "=",
      value     = "linux",
    },
  ]
}

variable "network" {
  description = "The group network configuration options."
  type = object({
    mode  = string
    ports = list(object({
      name   = string
      to     = number
      static = number
    }))
  })
  default = {
    mode = "bridge",
    ports = [
      {
        "name" = "http",
        "to" = 80,
        "static" = 4001,
      },
      {
        "name" = "db",
        "to" = 5432,
        "static" = 5432,
      }
    ]
  }
}

variable "app_service" {
  description = "Configuration for the application service."
  type = object({
    service_port_label = string
    service_name       = string
    service_tags       = list(string)
    check_enabled      = bool
    check_type         = string
    check_path         = string
    check_interval     = string
    check_timeout      = string
    upstreams = list(object({
      name = string
      port = number
    }))
  })
  default = null
}

variable "db_service" {
  description = "Configuration for the database service."
  type = object({
    service_port_label = string
    service_name       = string
    service_tags       = list(string)
    check_enabled      = bool
    check_type         = string
    check_path         = string
    check_interval     = string
    check_timeout      = string
    upstreams = list(object({
      name = string
      port = number
    }))
  })
  default = {
    service_port_label = "db",
    service_name       = "nextcloud-db",
    service_tags       = ["postgres"],
    upstreams          = [],
    check_enabled      = true,
    check_type         = "tcp",
    check_path         = "",
    check_interval     = "30s",
    check_timeout      = "2s",
  }
}

variable "app_resources" {
  description = "The resource to assign to the NextCloud app task."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 500,
    memory = 2048
  }
}

variable "db_resources" {
  description = "The resource to assign to the NextCloud app task."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 100,
    memory = 512
  }
}

variable "container_args" {
  description = "Arguments to pass to the Nextcloud container"
  type        = list(string)
  default = []
}

variable "env_vars" {
  description = "Nextcloud environment variables."
  type = list(object({
    key   = string
    value = string
  }))
  default = [
    {
      key   = "NEXTCLOUD_ADMIN_USER"
      value = "admin"
    },
    {
      key   = "NEXTCLOUD_ADMIN_PASSWORD"
      value = "password"
    },
    {
      key   = "NEXTCLOUD_DATA_DIR"
      value = "/var/www/html/data"
    }
  ]
}

variable "db_env_vars" {
  description = "Nextcloud environment variables."
  type = list(object({
    key   = string
    value = string
  }))
  default = [
    {
      key   = "POSTGRES_DB"
      value = "nextcloud"
    },
    {
      key   = "POSTGRES_USER"
      value = "nextcloud"
    },
    {
      key   = "POSTGRES_PASSWORD"
      value = "password"
    },
    {
      key   = "POSTGRES_HOST"
      value = "localhost"
    }
  ]
}

// VOLUME MOUNTS

variable "app_mounts" {
  description = "Mounts that are configured when using the default NextCloud configuration"
  type = list(object({
    type     = string
    source   = string
    target   = string
    readonly = bool
    bind_options = list(object({
      name  = string
      value = string
    }))
  }))
  default = [
    {
      type     = "bind"
      source   = "/var/nextcloud/html/data"
      target   = "/var/www/html/"
      readonly = false
      bind_options = []
    }
  ]
}

variable "postgres_mounts" {
  description = "password for postgres database"
    type = list(object({
    type     = string
    source   = string
    target   = string
    readonly = bool
    bind_options = list(object({
      name  = string
      value = string
    }))
  }))
  default     = [
    {
      type     = "bind"
      source   = "/var/nextcloud/postgresql/data"
      target   = "/var/lib/postgresql/data"
      readonly = false
      bind_options = []
    }
  ]
}

// DATABASE

variable "include_database_task" {
  description = "Whether or not to include a db task. If using a remote database, this should be false."
  type        = bool
  default     = true
}

variable "prestart_directory_creation" {
  description = "Whether or not to launch a prestart task to create volume directories on the host."
  type        = bool
  default     = true
}

variable "db_volume_source_path" {
  description = "Volume path on the host machine used for database data"
  type        = string
  default     = "/var/nextcloud/postgresql/data"
}

variable "app_data_source_path" {
  description = "Volume path on the host machine used for nextcloud application data"
  type        = string
  default     = "/var/nextcloud/html/data"
}

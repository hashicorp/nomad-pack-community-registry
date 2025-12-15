# Copyright IBM Corp. 2021, 2025
# SPDX-License-Identifier: MPL-2.0

// Job variables
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

variable "node_pool" {
  description = "The node pool where the job should be placed."
  type        = string
  default     = "default"
}

// MariaDB variables
variable "mariadb_group_update" {
  description = "The MariaDB update configuration options."
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

variable "mariadb_group_volume" {
  description = "The source volume name, as defined in Nomad's client configuration, to be used by MariaDB."
  type        = string
  default     = "wordpress-mariadb"
}

variable "mariadb_group_register_consul_service" {
  description = "If you want to register a consul service for the job."
  type        = bool
  default     = true
}

variable "mariadb_group_consul_service_name" {
  description = "The consul service name for the application."
  type        = string
  default     = "mariadb"
}

variable "mariadb_group_consul_service_port" {
  description = "The consul service port for the application."
  type        = string
  default     = "3306"
}

variable "mariadb_group_consul_tags" {
  description = ""
  type = list(string)
  default = [
    "database"
  ]
}

variable "mariadb_group_has_health_check" {
  description = "If you want to register a health check in consul. Port needs to be exposed."
  type        = bool
  default     = false
}

variable "mariadb_group_health_check" {
  description = ""
  type = object({
    port     = number
    interval = string
    timeout  = string
  })

  default = {
    port     = 3306
    interval = "10s"
    timeout  = "2s"
  }
}

variable "mariadb_group_restart_attempts" {
  description = "The number of times the task should restart on updates"
  type        = number
  default     = 2
}

variable "mariadb_task_image" {
  description = "MariaDB's Docker image."
  type        = string
  default     = "mariadb:10.6.4-focal"
}

variable "mariadb_task_volume_path" {
  description = "The volume's absolute path in the host, as defined in Nomad's client configuration, to be used by MariaDB."
  type        = string
  default     = "/var/lib/mariadb"
}

variable "mariadb_task_env_vars" {
  description = "MariaDB's environment variables."
  type = list(object({
    key   = string
    value = string
  }))
  default = [
    {
      key   = "MYSQL_ROOT_PASSWORD"
      value = "mariadb_root_password"
    },
    {
      key   = "MYSQL_DATABASE"
      value = "wordpress"
    },
    {
      key   = "MYSQL_USER"
      value = "wordpress"
    },
    {
      key   = "MYSQL_PASSWORD"
      value = "wordpress"
    }
  ]
}

variable "mariadb_task_resources" {
  description = "The resources to assign to the MariaDB service."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 256,
    memory = 256
  }
}

// WordPress variables
variable "wordpress_group_network" {
  description = ""
  type = list(object({
    name = string
    port = number
  }))

  default = [{
    name = "http"
    port = 80
  }]
}

variable "wordpress_group_update" {
  description = "The Wordpress update configuration options."
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

variable "wordpress_group_register_consul_service" {
  description = "If you want to register a consul service for the job."
  type        = bool
  default     = true
}

variable "wordpress_group_consul_service_name" {
  description = "The consul service name for the application."
  type        = string
  default     = "wordpress"
}

variable "wordpress_group_consul_service_port" {
  description = "The consul service port for the application."
  type        = string
  default     = "http"
}

variable "wordpress_group_consul_tags" {
  description = ""
  type = list(string)
  default = [
    "app"
  ]
}

variable "wordpress_group_upstreams" {
  description = "Consul Connect upstream configuration."
  type = list(object({
    name = string
    port = number
  }))
  default = [{
    name = "mariadb"
    port = 3306
  }]
}

variable "wordpress_group_has_health_check" {
  description = "If you want to register a health check in consul"
  type        = bool
  default     = true
}

variable "wordpress_group_health_check" {
  description = ""
  type = object({
    name     = string
    path     = string
    port     = string
    interval = string
    timeout  = string
  })

  default = {
    name     = "wordpress"
    path     = "/wp-admin/install.php"
    port     = "http"
    interval = "10s"
    timeout  = "2s"
  }
}

variable "wordpress_group_restart_attempts" {
  description = "The number of times the task should restart on updates"
  type        = number
  default     = 2
}

variable "wordpress_task_image" {
  description = "Wordpress Docker image."
  type        = string
  default     = "wordpress:5.8.1-apache"
}

variable "wordpress_task_env_vars" {
  description = "Wordpress environment variables."
  type = list(object({
    key   = string
    value = string
  }))
    default = [
    {
      key   = "WORDPRESS_DB_HOST"
      value = "$${NOMAD_UPSTREAM_ADDR_mariadb}"
    },
    {
      key   = "WORDPRESS_DB_USER"
      value = "wordpress"
    },
    {
      key   = "WORDPRESS_DB_PASSWORD"
      value = "wordpress"
    },
    {
      key   = "WORDPRESS_DB_NAME"
      value = "wordpress"
    }
  ]
}

variable "wordpress_task_resources" {
  description = "The resources to assign to the Wordpress service."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 256,
    memory = 256
  }
}

// phpMyAdmin variables
variable "phpmyadmin_group_network" {
  description = ""
  type = list(object({
    name = string
    port = number
  }))

  default = [{
    name = "http"
    port = 80
  }]
}

variable "phpmyadmin_group_update" {
  description = "The phpmyadmin update configuration options."
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

variable "phpmyadmin_group_register_consul_service" {
  description = "If you want to register a consul service for the job."
  type        = bool
  default     = true
}

variable "phpmyadmin_group_consul_service_name" {
  description = "The consul service name for the application."
  type        = string
  default     = "phpmyadmin"
}

variable "phpmyadmin_group_consul_service_port" {
  description = "The consul service port for the application."
  type        = string
  default     = "http"
}

variable "phpmyadmin_group_consul_tags" {
  description = ""
  type = list(string)
  default = [
    "app"
  ]
}

variable "phpmyadmin_group_upstreams" {
  description = "Consul Connect upstream configuration."
  type = list(object({
    name = string
    port = number
  }))
  default = [{
    name = "mariadb"
    port = 3306
  }]
}

variable "phpmyadmin_group_has_health_check" {
  description = "If you want to register a health check in consul."
  type        = bool
  default     = true
}

variable "phpmyadmin_group_health_check" {
  description = ""
  type = object({
    name     = string
    path     = string
    port     = string
    interval = string
    timeout = string
  })

  default = {
    name     = "phpmyadmin"
    path     = "/"
    port     = "http"
    interval = "10s"
    timeout  = "2s"
  }
}

variable "phpmyadmin_group_restart_attempts" {
  description = "The number of times the task should restart on updates."
  type        = number
  default     = 2
}

variable "phpmyadmin_task_image" {
  description = "phpmyadmin Docker image."
  type        = string
  default     = "phpmyadmin:5.1.1-apache"
}

variable "phpmyadmin_task_env_vars" {
  description = "phpmyadmin environment variables."
  type = list(object({
    key   = string
    value = string
  }))
    default = [
    {
      key   = "MYSQL_ROOT_PASSWORD"
      value = "mariadb_root_password"
    },
    {
      key   = "PMA_HOST"
      value = "$${NOMAD_UPSTREAM_IP_mariadb}"
    },
    {
      key   = "PMA_PORT"
      value = "$${NOMAD_UPSTREAM_PORT_mariadb}"
    },
    {
      key   = "MYSQL_USERNAME"
      value = "wordpress"
    }
  ]
}

variable "phpmyadmin_task_resources" {
  description = "The resources to assign to the phpmyadmin service."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 128,
    memory = 128
  }
}

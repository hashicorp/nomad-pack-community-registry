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

variable "constraints" {
  description = "Constraints to apply to the entire job."
  type        = list(object({
    attribute = string
    operator  = string
    value     = string
  }))
  default = [
    {
      attribute = "$${attr.kernel.name}",
      value     = "linux",
      operator  = "",
    },
  ]
}

variable "traefik_group_network" {
  description = "The Traefik network configuration options."
  type        = object({
    mode  = string
    ports = map(number)
    dns = map(list(string))
  })
  default = {
    mode  = "bridge",
    ports = {
      "http" = 8080,
      "https" = 8443,
      "api"  = 1936,
    },
    dns = {}
  }
}

variable "traefik_task" {
  description = ""
  type        = object({
    driver  = string
    version = string
  })
  default     = {
    driver  = "docker",
    version = "2.5",
  }
}

variable "traefik_task_dynamic_config" {
  description = "The TOML Traefik dynamic configuration to pass to the task."
  type        = string
  default     = null
}

variable "traefik_task_app_config" {
  description = "The TOML Traefik configuration to pass to the task."
  type        = string
  default     = <<EOF
[entryPoints]
  [entryPoints.http]
  address = ":8080"
  [entryPoints.traefik]
  address = ":1936"

[api]
  dashboard = true
  insecure = true

[providers]
  [providers.consulCatalog]
    prefix           = "traefik"
    exposedByDefault = false

[providers.consulCatalog.endpoint]
  address = "{{ env "attr.unique.network.ip-address" }}:8500"
  scheme  = "http"
EOF
}

variable "traefik_task_resources" {
  description = "The resource to assign to the Traefik task."
  type        = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 200,
    memory = 256,
  }
}

variable "traefik_task_services" {
  description = "Configuration options of the Traefik services and checks."
  type        = list(object({
    service_port_label = string
    service_name       = string
    service_tags       = list(string)
    check_enabled      = bool
    check_type         = string
    check_path         = string
    check_interval     = string
    check_timeout      = string
  }))
  default = [
    {
      service_port_label = "http",
      service_name       = "traefik-http",
      service_tags       = [],
      check_enabled      = true,
      check_type         = "tcp",
      check_path         = "",
      check_interval     = "3s",
      check_timeout      = "1s",
    },
    {
      service_port_label = "api",
      service_name       = "traefik-api",
      service_tags       = [],
      check_enabled      = true,
      check_type         = "tcp",
      check_path         = "",
      check_interval     = "3s",
      check_timeout      = "1s",
    }
  ]
}

variable "traefik_vault" {
  description = "List of Vault Policies"
  type = list(string)
  default = null
  }

variable "traefik_task_cacert" {
  description = "CA for using external SSL"
  type = string
  default = null
  }

variable "traefik_task_cert" {
  description = "Certificate for using external SSL"
  type = string
  default = null
  }

variable "traefik_task_cert_key" {
  description = "Certificate private key for using external SSL"
  type = string
  default = null
  }

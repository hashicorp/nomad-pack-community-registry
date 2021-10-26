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

variable "version_tag" {
  description = "The docker image version. For options, see https://hub.docker.com/grafana/promtail"
  type        = string
  default     = "latest"
}

variable "config_file" {
  description = "Path to custom Promtail configuration file."
  type        = string
  default     = ""
}

// Default config options used when no config file is specified
variable "client_urls" {
  description = "A list of client url's for promtail to send it's data to."
  type        = list(string)
  default     = []
}

variable "journal_max_age" {
  description = "Maximum age of journald entries to scrape."
  type        = string
  default     = "12h"
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
      value     = "linux",
      operator  = "",
    },
  ]
}

variable "promtail_group_network" {
  description = "The Promtail network configuration options."
  type = object({
    mode  = string
    ports = map(number)
  })
  default = {
    mode = "bridge",
    ports = {
      "http" = 9090,
    },
  }
}

variable "promtail_group_services" {
  description = "Configuration options of the promtail services and checks."
  type = list(object({
    service_port_label = string
    service_name       = string
    service_tags       = list(string)
    check_enabled      = bool
    check_path         = string
    check_interval     = string
    check_timeout      = string
    upstreams = list(object({
      name = string
      port = number
    }))
  }))
  default = [{
    service_port_label = "http",
    service_name       = "promtail",
    service_tags       = [],
    upstreams          = [],
    check_enabled      = true,
    check_path         = "/ready",
    check_interval     = "3s",
    check_timeout      = "1s",
  }]
}

variable "resources" {
  description = "The resource to assign to the promtail service task."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 200,
    memory = 256
  }
}

variable "container_args" {
  description = "Arguments passed to the Promtail docker container"
  type        = list(string)
  default = [
    "-config.file=/etc/promtail/promtail-config.yaml",
    "-log.level=info"
  ]
}

variable "extra_mounts" {
  description = "Additional mounts to create in the Promtail container"
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
  default = []
}

variable "default_mounts" {
  description = "Mounts that are configured when using the default Promtail configuration"
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
      target   = "/var/log/journal"
      source   = "/var/log/journal"
      readonly = true
      bind_options = [
        {
          name  = "propagation"
          value = "rshared"
        },
      ]
    },
    {
      type     = "bind"
      target   = "/etc/machine-id"
      source   = "/etc/machine-id"
      readonly = false
      bind_options = [
        {
          name  = "propagation",
          value = "rshared"
        },
      ]
    }
  ]
}
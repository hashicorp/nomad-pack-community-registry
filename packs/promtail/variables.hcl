variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name."
  type        = string
  // If "", the pack name will be used
  default     = ""
}

variable "service_name" {
  description = "Name used to register the Consul Service"
  type		    = string
  default     = "promtail"
}

variable "service_check_name" {
  description = "Name of the service check registered with the Consul Service"
  type		    = string
  default     = "Readiness"
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

variable "http_port" {
  description = "The Nomad client port that routes to the Promtail."
  type        = number
  default     = 9080
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

variable "config_file" {
  description = "Path to custom Promtail configuration file."
  type		= string
  default = ""
}

variable "mount_journal" {
  description = "Controls whether /var/log/journal is mounted in the container. If true, container will be run privileged."
  type		= bool
  default = true
}

variable "mount_machine_id" {
  description = "Controls whether /etc/machine-id is mounted in the container. If true, container will be run privileged."
  type		= bool
  default = true
}

// Default configuration mounts paths /var/log/journal and /etc/machine-id from 
//   the nomad client. This requires a privileged container.
variable "privileged_container" {
  description = "Run as a privileged container. Setting mount_journal or mount_machine_id to true will override this."
  type		= bool
  default = false
}

// Default config options used when no config file is specified
variable "client_urls" {
  description = "A list of client url's for promtail to send it's data to."
  type		= list(string)
  default = []
}

variable "journal_max_age" {
  description = "Maximum age of journald entries to scrape."
  type		= string
  default = "12h"
}

variable "log_level" {
  description = "Promtail log level configuration."
  type		= string
  default = "info"
}

variable "upstreams" {
  description = "Define Connect Upstreams used by Promtail."
  type = list(object({
    name = string
    port = number
  }))
  default = []
}
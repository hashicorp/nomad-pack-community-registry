variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name."
  type = string
  default = "chaotic-ngine"
}

variable "priority" {
  description = "The priority of the job."
  type = number
  default = 10
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement."
  type = list(string)
  default = ["dc1"]
}

variable "region" {
  description = "The region where the job should be placed."
  type = string
  default = "global"
}

variable "namespace" {
  description = "The namespace where the job should be placed."
  type = string
  default = "default"
}

variable "constraints" {
  description = "Constraints to apply to the entire job."
  type = list(object({
    attribute = string
    operator = string
    value = string
  }))
  default = [
    {
      attribute = "$${attr.kernel.name}",
      value = "linux",
      operator  = "",
    },
  ]
}

variable "image_version" {
  description = "Version of the image used."
  type = string
  default = "latest"
}

// see https://github.com/ngine-io/chaotic#nomad
variable "config" {
  description = "Path to the config to configure the job statically. Mutually exclusive with config_template_url."
  type = string
  default = <<EOF
---
kind: nomad
dry_run: false
excludes:
  weekdays:
    - Sun
    - Sat
  times_of_day:
    - 22:00-08:00
    - 11:00-14:00
  days_of_year:
    - Jan01
    - Apr01
    - May01
    - Aug01
    - Dec24
configs:
  namespace_denylist:
    - default
  signals:
    - SIGKILL
EOF
}

variable "config_template_url" {
  description = "URL where the config should be read from when the job starts. Mutually exclusive with config."
  type = string
  default = ""
}

variable "timezone" {
  description = "Timezone the job is related to."
  type = string
  default = "Etc/UTC"
}

// e.g. "http://172.17.0.1:4646"
variable "nomad_addr" {
  description = "Address of the nomad API"
  type = string
  default = ""
}

variable "cron" {
  description = "Cron when to run the job."
  type = string
  default = "13 * * * * *"
}

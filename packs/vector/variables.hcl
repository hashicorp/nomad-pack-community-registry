variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name."
  type        = string
  default     = ""
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for job placement."
  type        = list(string)
  default     = ["dc1"]
}

variable "region" {
  description = "The region where the job should be placed."
  type        = string
  default     = "global"
}

variable "namespace" {
  description = "The namespace where the job should be placed."
  type        = string
  default     = "default"
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

variable "vector_group_network" {
  description = "The Vector network configuration options."
  type        = object({
    mode     = string
    hostname = string
    ports    = map(number)
  })
  default = {
    mode  = "bridge",
    hostname = "$${attr.unique.hostname}"
    ports = {
      "api" = 8686,
    },
  }
}

variable "vector_group_update" {
  description = "The Vector update configuration options."
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

variable "vector_group_ephemeral_disk" {
  description = "The Vector ephemeral_disk configuration options."
  type        = object({
    migrate = bool
    size    = number
    sticky  = bool
  })
  default = {
    migrate = true,
    size    = 300,
    sticky  = true,
  }
}

variable "vector_task" {
  description = "Details configuration options for the Vector task."
  type        = object({
    driver   = string
    version  = string
  })
  default = {
    driver   = "docker",
    version  = "0.17.3-alpine",
  }
}

variable "vector_task_bind_mounts" {
  description = "The bind mounts paths to be used by Vector"
  type        = object({
    source_procfs_root_path   = string
    source_sysfs_root_path    = string
    source_docker_socket_path = string
    target_procfs_root_path   = string
    target_sysfs_root_path    = string
    target_docker_socket_path = string
  })
  default = {
    source_procfs_root_path   = "/proc",
    source_sysfs_root_path    = "/sys",
    source_docker_socket_path = "/var/run/docker.sock",
    target_procfs_root_path   = "/host/proc",
    target_sysfs_root_path    = "/host/sys",
    target_docker_socket_path = "/host/var/run/docker.sock",
  }
}

variable "vector_task_loki_prometheus" {
  description = "The endpoints and credentials of Loki and Prometheus."
  type        = object({
    loki_endpoint_url       = string
    loki_username           = string
    loki_password           = string
    prometheus_endpoint_url = string
    prometheus_username     = string
    prometheus_password     = string
  })
  default = {
    loki_endpoint_url       = "http://127.0.0.1:3100",
    loki_username           = "",
    loki_password           = "",
    prometheus_endpoint_url = "http://127.0.0.1:9090",
    prometheus_username     = "",
    prometheus_password     = "",
  }
}

variable "vector_task_data_config_toml" {
  description = "The Vector configuration to pass to the task."
  type        = string
  default     = <<EOF
data_dir                     = "alloc/data/vector/"
healthchecks.require_healthy = true

[api]
  enabled              = true
  address              = "0.0.0.0:8686"
  playground           = false

[sources.docker_logs]
  type                 = "docker_logs"
  docker_host          = "$${DOCKER_SOCKET_PATH}"
  exclude_containers   = ["vector-"]
[sinks.loki]
  type                 = "loki"
  inputs               = [ "docker_logs" ]
  endpoint             = "$${LOKI_ENDPOINT_URL}"
  auth.strategy        = "basic"
  auth.user            = "$${LOKI_USERNAME}"
  auth.password        = "$${LOKI_PASSWORD}"
  encoding.codec       = "json"
  healthcheck.enabled  = true
  labels.job           = "{{ label.com\\.hashicorp\\.nomad\\.job_name }}"
  labels.task          = "{{ label.com\\.hashicorp\\.nomad\\.task_name }}"
  labels.group         = "{{ label.com\\.hashicorp\\.nomad\\.task_group_name }}"
  labels.namespace     = "{{ label.com\\.hashicorp\\.nomad\\.namespace }}"
  labels.node          = "{{ label.com\\.hashicorp\\.nomad\\.node_name }}"
  labels.job_id        = "{{ label.com\\.hashicorp\\.nomad\\.job_id }}"
  labels.node_id       = "{{ label.com\\.hashicorp\\.nomad\\.node_id }}"
  remove_label_fields  = true

[sources.host_metrics]
  type                 = "host_metrics"
  scrape_interval_secs = 10
[sources.nomad_metrics]
  type                 = "prometheus_scrape"
  scrape_interval_secs = 10
  endpoints            = [ "http://$${NOMAD_HOST_IP_api}:4646/v1/metrics?format=prometheus" ]
[sinks.prometheus_remote_write]
  type                 = "prometheus_remote_write"
  inputs               = [ "host_metrics", "nomad_metrics" ]
  endpoint             = "$${PROMETHEUS_ENDPOINT_URL}"
  auth.strategy        = "basic"
  auth.user            = "$${PROMETHEUS_USERNAME}"
  auth.password        = "$${PROMETHEUS_PASSWORD}"
  healthcheck.enabled  = false
EOF
}

variable "vector_task_resources" {
  description = "The resource to assign to the Vector task."
  type        = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 64,
    memory = 64,
  }
}

variable "vector_task_services" {
  description = "Configuration options of the Vector services and checks."
  type        = list(object({
    service_port_label = string
    service_name       = string
    service_tags       = list(string)
    check_enabled      = bool
    check_path         = string
    check_interval     = string
    check_timeout      = string
  }))
  default = [{
    service_port_label = "api",
    service_name       = "vector",
    service_tags       = ["observability"],
    check_enabled      = true,
    check_path         = "/health",
    check_interval     = "3s",
    check_timeout      = "1s",
  }]
}

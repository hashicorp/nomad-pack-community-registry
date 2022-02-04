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

variable "job_type" {
  description = "The type of the job."
  type        = string
  default     = "system"
}

variable "instance_count" {
  description = "In case the job is ran as a service, how many copies of the opentelemetry_collector group to run."
  type        = number
  default     = 1
}

variable "privileged_mode" {
  description = "Determines if the OpenTelemetry Collector should run with privleged access to the host. Useful when using the hostmetrics receiver."
  type        = bool
  default     = false
}

variable "task_config" {
  description = "The OpenTelemetry Collector task config options."
  type = object({
    image   = string
    version = string
    env     = map(string)
  })
  default = {
    image   = "otel/opentelemetry-collector-contrib"
    version = "latest"
    env     = {}
  }
}

variable "vault_config" {
  description = "The OpenTelemetry Collector job's Vault configuration. Set `enabled = true` to configure the job to use vault See: https://www.nomadproject.io/docs/job-specification/vault"
  type = object({
    enabled       = bool
    policies      = list(string)
    change_mode   = string
    change_signal = string
    env           = bool
    namespace     = string
  })
  default = {
    enabled       = false
    policies      = []
    change_mode   = "restart"
    change_signal = ""
    env           = true
    namespace     = ""
  }
}

variable "network_config" {
  description = "The OpenTelemetry Collector network configuration options."
  type = object({
    mode  = string
    ports = map(number)
  })
  default = {
    mode = "bridge"
    ports = {
      "otlp"               = 4317
      "otlphttp"           = 4318
      "metrics"            = 8888
      "zipkin"             = 9411
      "healthcheck"        = 13133
      "jaeger-grpc"        = 14250
      "jaeger-thrift-http" = 14268
      "zpages"             = 55679
    }
  }
}

variable "resources" {
  description = "The resources to assign to the OpenTelemetry Collector task."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 256
    memory = 512
  }
}

variable "config_yaml" {
  description = "The OpenTelemetry Collector configuration to pass to the task."
  type        = string
  default     = <<EOF
---
receivers:
  otlp:
    protocols:
      grpc:
      http:
  jaeger:
    protocols:
      grpc:
      thrift_http:
  zipkin: {}

processors:
  batch: {}

extensions:
  health_check: {}
  zpages: {}

exporters:
  otlp:
    endpoint: "someotlp.target.com:443"
    headers:
      "x-someapi-header": "$SOME_API_KEY"
  logging:
    loglevel: info

service:
  extensions: [health_check, zpages]
  pipelines:
    traces:
      receivers: [otlp, jaeger, zipkin]
      processors: [batch]
      exporters: [otlp, logging]
    metrics:
      receivers: [otlp]
      processors: [batch]
      exporters: [otlp, logging]
EOF
}

variable "additional_templates" {
  description = "Additional job templates: access Consul KV, or the Vault KV or secrets engine. 'data' and 'destination' are required."
  type = list(object({
    data          = string
    desination    = string
    change_mode   = string
    change_signal = string
    env           = bool
    perms         = string
  }))
  default = []
}

variable "task_services" {
  description = "Configuration options of the OpenTelemetry Collector services and checks."
  type = list(object({
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
      service_port_label = "otlp"
      service_name       = "opentelemetry-collector"
      service_tags       = []
      check_enabled      = false
      check_type         = "tcp"
      check_path         = "/"
      check_interval     = "15s"
      check_timeout      = "3s"
    },
    {
      service_port_label = "otlphttp"
      service_name       = "opentelemetry-collector"
      service_tags       = ["otlphttp"]
      check_enabled      = false
      check_type         = "http"
      check_path         = "/"
      check_interval     = "15s"
      check_timeout      = "3s"
    },
    {
      service_port_label = "metrics"
      service_name       = "opentelemetry-collector"
      service_tags       = ["prometheus"]
      check_enabled      = false
      check_type         = "http"
      check_path         = "/"
      check_interval     = "15s"
      check_timeout      = "3s"
    },
    {
      service_port_label = "zipkin"
      service_name       = "opentelemetry-collector"
      service_tags       = ["zipkin"]
      check_enabled      = false
      check_type         = "http"
      check_path         = "/"
      check_interval     = "15s"
      check_timeout      = "3s"
    },
    {
      service_port_label = "healthcheck"
      service_name       = "opentelemetry-collector"
      service_tags       = ["health"]
      check_enabled      = true
      check_type         = "http"
      check_path         = "/"
      check_interval     = "15s"
      check_timeout      = "3s"
    },
    {
      service_port_label = "jaeger-grpc"
      service_name       = "opentelemetry-collector"
      service_tags       = ["jaeger-grpc"]
      check_enabled      = false
      check_type         = "tcp"
      check_path         = "/"
      check_interval     = "15s"
      check_timeout      = "3s"
    },
    {
      service_port_label = "jaeger-thrift-http"
      service_name       = "opentelemetry-collector"
      service_tags       = ["jaeger-thrift-http"]
      check_enabled      = false
      check_type         = "http"
      check_path         = "/"
      check_interval     = "15s"
      check_timeout      = "3s"
    },
    {
      service_port_label = "zpages"
      service_name       = "opentelemetry-collector"
      service_tags       = ["zpages"]
      check_enabled      = false
      check_type         = "http"
      check_path         = "/"
      check_interval     = "15s"
      check_timeout      = "3s"
  }]
}

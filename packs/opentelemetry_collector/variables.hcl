variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name"
  type        = string
  // If "", the pack name will be used
  default = ""
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement"
  type        = list(string)
  default     = ["dc1"]
}

variable "region" {
  description = "The region where the job should be placed"
  type        = string
  default     = "global"
}

variable "consul_service_name" {
  description = "The consul service you wish to load balance"
  type        = string
  default     = "telemetry"
}

variable "container_registry" {
  description = "The docker registry to pull the image from."
  type        = string
  default     = ""
}

variable "container_image_name" {
  description = "The name of the image to pull."
  type        = string
  default     = "otel/opentelemetry-collector"
}

variable "container_version_tag" {
  description = "The docker image version. For options, see https://hub.docker.com/r/otel/opentelemetry-collector"
  type        = string
  default     = "0.38.0"
}

variable "network_ports" {
  description = "A list of maps describing the ports in the network stanza"
  type = list(object({
    name = string
    port = number
  }))
  default = [
    {
      name = "otpl"
      port = 4317
    },
    {
      name = "metrics"
      port = 8888
    }
  ]
}

variable "config_yaml" {
  description = "The YAML config for the collector."
  type        = string
  default     = <<-EOF
  ---
  receivers:
    otlp:
      protocols:
        grpc:
        http:

  processors:
    batch:

  extensions:
    health_check: {}
    zpages: {}

  exporters:
    file:
      path: ./dump.json

  service:
    extensions: [health_check, zpages]
    pipelines:
      metrics:
        receivers: [otlp]
        processors: [batch]
        exporters: [file]
      traces:
        receivers: [otlp]
        processors: [batch]
        exporters: [file]
      logs:
        receivers: [otlp]
        processors: [batch]
        exporters: [file]
  EOF
}

variable "resources" {
  description = "The resource to assign to the OpenTelemetry Collector system task that runs on every client"
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 500,
    memory = 2048
  }
}

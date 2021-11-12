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
    jaeger:
      protocols:
        grpc:
        thrift_http:
    zipkin: {}

  processors:
    batch:
    memory_limiter:
      # Same as --mem-ballast-size-mib CLI argument
      ballast_size_mib: 683
      # 80% of maximum memory up to 2G
      limit_mib: 1500
      # 25% of limit up to 2G
      spike_limit_mib: 512
      check_interval: 5s

  extensions:
    health_check: {}
    zpages: {}

  exporters:
    prometheus:
      endpoint: "localhost:8889"
      namespace: "default"

  service:
    extensions: [health_check, zpages]
    pipelines:
      metrics:
        receivers: [otlp]
        exporters: [prometheus]
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

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

variable "config_yaml_path" {
  description = "The YAML config for the collector."
  type        = string
  default     = "templates/otel_config.yaml"
}

variable "resources" {
  description = "The resource to assign to the OpenTelemetry Collector system task that runs on every client"
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 200,
    memory = 256
  }
}

variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name."
  type        = string
  // If "", the pack name will be used
  default = ""
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
  description = "The docker image version. For options, see https://hub.docker.com/r/grafana/tempo"
  type        = string
  default     = "1.1.0"
}

variable "http_port" {
  description = "The Nomad client port that routes to the tempo."
  type        = number
  default     = 3200
}

variable "grpc_port" {
  description = "The Nomad client port that routes to the tempo."
  type        = number
  default     = 9095
}

variable "resources" {
  description = "The resource to assign to the tempo service task."
  type = object({
    cpu    = number
    memory = number
  })
  default = {
    cpu    = 200,
    memory = 256
  }
}

variable "register_consul_service" {
  description = "If you want to register a consul service for the job"
  type        = bool
  default     = true
}

variable "register_consul_connect_enabled" {
  description = "If you want to run the consul service with connect enabled. This will only work with register_consul_service = true"
  type        = bool
  default     = true
}

variable "consul_service_name" {
  description = "The consul service name for the hello-world application"
  type        = string
  default     = "tempo"
}

variable "consul_service_tags" {
  description = "The consul service name for the hello-world application"
  type        = list(string)
  // defaults to integrate with Fabio or Traefik
  // This routes at the root path "/", to route to this service from
  // another path, change "urlprefix-/" to "urlprefix-/<PATH>" and
  // "traefik.http.routers.http.rule=Path(`/`)" to
  // "traefik.http.routers.http.rule=Path(`/<PATH>`)"
  default = [
    "urlprefix-/",
    "traefik.enable=true",
    "traefik.http.routers.http.rule=Path(`/`)",
  ]
}

variable "tempo_yaml" {
  description = "The Tempo configuration to pass to the task."
  type        = string
  // defaults as used in the upstream getting started tutorial.
  default     = <<EOF
server:
  http_listen_port: 3200
distributor:
  receivers:
    jaeger:
      protocols:
        thrift_http:
        grpc:
        thrift_binary:
        thrift_compact:
    zipkin:
    otlp:
      protocols:
        http:
        grpc:
    opencensus:
ingester:
  trace_idle_period: 10s
  max_block_bytes: 1_000_000
  max_block_duration: 5m
compactor:
  compaction:
    compaction_window: 1h
    max_block_bytes: 100_000_000
    block_retention: 1h
    compacted_block_retention: 10m
storage:
  trace:
    backend: local
    block:
      bloom_filter_false_positive: .05
      index_downsample_bytes: 1000
      encoding: zstd
    wal:
      path: /tmp/tempo/wal
      encoding: snappy
    local:
      path: /tmp/tempo/blocks
    pool:
      max_workers: 100
      queue_depth: 10000
EOF
}

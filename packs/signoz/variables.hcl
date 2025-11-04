variable "job_name" {
  # If "", the pack name will be used
  description = "The name to use as the job name which overrides using the pack name"
  type        = string
  default     = "signoz"
}

variable "region" {
  description = "The region where jobs will be deployed"
  type        = string
  default     = ""
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement"
  type        = list(string)
  default     = ["*"]
}

variable "clickhouse_version" {
  description = "ClickHouse version to deploy"
  type        = string
  default     = "25.5.6"
}

variable "clickhouse_http_port" {
  description = "ClickHouse HTTP port"
  type        = number
  default     = 8123
}

variable "clickhouse_tcp_port" {
  description = "ClickHouse TCP port"
  type        = number
  default     = 9000
}

variable "clickhouse_cpu" {
  description = "CPU allocation for ClickHouse (MHz)"
  type        = number
  default     = 100
}

variable "clickhouse_memory" {
  description = "Memory allocation for ClickHouse (MB)"
  type        = number
  default     = 512
}

variable "clickhouse_volume_name" {
  description = "Name of the host volume for ClickHouse data"
  type        = string
  default     = "clickhouse-data"
}

variable "clickhouse_cluster_name" {
  description = "ClickHouse cluster name"
  type        = string
  default     = "cluster"
}

variable "clickhouse_user" {
  description = "ClickHouse username"
  type        = string
  default     = "default"
}

variable "clickhouse_password" {
  description = "ClickHouse password"
  type        = string
  default     = ""
}

variable "clickhouse_secure" {
  description = "Whether to use secure ClickHouse connections"
  type        = string
  default     = "false"
}

variable "clickhouse_shards" {
  description = "Number of ClickHouse shards"
  type        = string
  default     = "1"
}

variable "clickhouse_replicas" {
  description = "Number of ClickHouse replicas"
  type        = string
  default     = "1"
}

# ZooKeeper Configuration
variable "zookeeper_count" {
  description = "Number of ZooKeeper instances to deploy"
  type        = number
  default     = 1
}

variable "zookeeper_cpu" {
  description = "CPU allocation for ZooKeeper (MHz)"
  type        = number
  default     = 100
}

variable "zookeeper_memory" {
  description = "Memory allocation for ZooKeeper (MB)"
  type        = number
  default     = 512
}

variable "zookeeper_volume_name" {
  description = "Name of the host volume for ZooKeeper data"
  type        = string
  default     = "zookeeper-data"
}

# SigNoz Configuration
variable "signoz_count" {
  description = "Number of SigNoz instances to deploy"
  type        = number
  default     = 1
}

variable "signoz_version" {
  description = "SigNoz version to deploy"
  type        = string
  default     = "v0.95.0"
}

variable "signoz_http_port" {
  description = "SigNoz HTTP port"
  type        = number
  default     = 8080
}

variable "signoz_internal_port" {
  description = "SigNoz internal HTTP port"
  type        = number
  default     = 8085
}

variable "signoz_opamp_port" {
  description = "SigNoz OpAMP port"
  type        = number
  default     = 4320
}

variable "signoz_cpu" {
  description = "CPU allocation for SigNoz (MHz)"
  type        = number
  default     = 100
}

variable "signoz_memory" {
  description = "Memory allocation for SigNoz (MB)"
  type        = number
  default     = 100
}

variable "signoz_volume_name" {
  description = "Name of the host volume for SigNoz data"
  type        = string
  default     = "signoz-db"
}

# OpenTelemetry Collector Configuration
variable "otel_collector_count" {
  description = "Number of OTEL Collector instances to deploy"
  type        = number
  default     = 1
}

variable "otel_collector_version" {
  description = "OTEL Collector version to deploy"
  type        = string
  default     = "v0.129.5"
}

variable "otel_collector_metrics_port" {
  description = "OTEL Collector metrics port"
  type        = number
  default     = 8888
}

variable "otel_collector_otlp_port" {
  description = "OTEL Collector OTLP gRPC port"
  type        = number
  default     = 4317
}

variable "otel_collector_otlp_http_port" {
  description = "OTEL Collector OTLP HTTP port"
  type        = number
  default     = 4318
}

variable "otel_collector_health_port" {
  description = "OTEL Collector health check port"
  type        = number
  default     = 13133
}

variable "otel_collector_cpu" {
  description = "CPU allocation for OTEL Collector (MHz)"
  type        = number
  default     = 200
}

variable "otel_collector_memory" {
  description = "Memory allocation for OTEL Collector (MB)"
  type        = number
  default     = 256
}


# Schema Migrator Configuration
variable "schema_migrator_version" {
  description = "Schema migrator version to deploy"
  type        = string
  default     = "v0.129.5"
}

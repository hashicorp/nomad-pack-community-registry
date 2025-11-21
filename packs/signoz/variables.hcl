# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "config" {
  description = "The path to find a directory of configuration files"
  type = string
}

variable "release_name" {
  # If "", the pack name will be used
  description = "The name to use as the job name which overrides using the pack name"
  type        = string
  default     = "signoz"
}

variable "namespace" {
  description = "The namespace where jobs will be deployed"
  type        = string
  default     = "default"
}

variable "region" {
  description = "The region where jobs will be deployed"
  type        = string
  default     = "" # defaults to global region
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement"
  type        = list(string)
  default     = ["*"]
}

variable "node_pool" {
  description = "The node pool where the job should be placed."
  type        = string
  default     = "default"
}

# Zookeeper configuration

variable "zookeeper_volume_name" {
  description = "Name of the host volume for ZooKeeper data"
  type        = string
  default     = "zookeeper-data"
}

# Clickhouse configurations

variable "clickhouse_volume_name" {
  description = "Name of the host volume for ClickHouse data"
  type        = string
  default     = "clickhouse-data"
}

variable "signoz_volume_name" {
  description = "Name of the host volume for SigNoz data"
  type        = string
  default     = "signoz-data"
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
  default     = 250
}

variable "clickhouse_memory" {
  description = "Memory allocation for ClickHouse (MB)"
  type        = number
  default     = 512
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
variable "zookeeper_version" {
  description = "Zookeeper version to deploy"
  type        = string
  default     = "3.7.1"
}
variable "zookeeper_count" {
  description = "Number of ZooKeeper instances to deploy"
  type        = number
  default     = 1
}

variable "zookeeper_cpu" {
  description = "CPU allocation for ZooKeeper (MHz)"
  type        = number
  default     = 250
}

variable "zookeeper_memory" {
  description = "Memory allocation for ZooKeeper (MB)"
  type        = number
  default     = 1024
}


variable "signoz_version" {
  description = "SigNoz version to deploy"
  type        = string
  default     = "v0.100.0"
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
  default     = "v0.129.8"
}

variable "schema_migrator_cpu" {
  description = "CPU allocation for OTEL Collector (MHz)"
  type        = number
  default     = 200
}

variable "schema_migrator_memory" {
  description = "Memory allocation for OTEL Collector (MB)"
  type        = number
  default     = 256
}

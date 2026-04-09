# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# ── Job basics ────────────────────────────────────────────────────────────────

variable "job_name" {
  description = "Name of the Nomad job."
  type        = string
  default     = "nomad-snapshot-agent"
}

variable "datacenters" {
  description = "Datacenters eligible for task placement."
  type        = list(string)
  default     = ["dc1"]
}

variable "region" {
  description = "Nomad region for the job."
  type        = string
  default     = "global"
}

variable "namespace" {
  description = "Nomad namespace for the job."
  type        = string
  default     = "default"
}

variable "nomad_binary" {
  description = "Absolute path to the nomad binary on the host."
  type        = string
  default     = "/usr/local/bin/nomad"   ## Chnage the path as per your envoironment.
}

# ── Nomad connection ──────────────────────────────────────────────────────────

variable "nomad_addr" {
  description = "Address of the Nomad server the snapshot agent connects to."
  type        = string
  default     = "http://127.0.0.1:4646"
}

variable "nomad_region" {
  description = "Nomad region passed to the snapshot agent config."
  type        = string
  default     = ""
}

variable "nomad_token" {
  description = "ACL token with operator:write or operator:snapshot-save + operator:license-read. Required if ACLs are enabled."
  type        = string
  default     = ""
}

# ── TLS ───────────────────────────────────────────────────────────────────────

variable "tls_enabled" {
  description = "Enable TLS for the snapshot agent → Nomad connection."
  type        = bool
  default     = false
}

variable "tls_ca_file" {
  description = "Path to PEM encoded CA cert file on the host. Used when tls_enabled = true."
  type        = string
  default     = "/etc/nomad.d/tls/ca.crt"
}

variable "tls_cert_file" {
  description = "Path to PEM encoded client cert on the host. Used when tls_enabled = true."
  type        = string
  default     = "/etc/nomad.d/tls/client.crt"
}

variable "tls_key_file" {
  description = "Path to PEM encoded client key on the host. Used when tls_enabled = true."
  type        = string
  default     = "/etc/nomad.d/tls/client.key"
}

variable "tls_server_name" {
  description = "SNI server name for TLS connections."
  type        = string
  default     = ""
}

# ── Snapshot settings ─────────────────────────────────────────────────────────

variable "snapshot_interval" {
  description = "How often to take a snapshot. Suffix: s, m, h. Set 0 for one-shot mode."
  type        = string
  default     = "24h"
}

variable "snapshot_retain" {
  description = "Number of snapshots to retain before the oldest are deleted. 0 = keep forever."
  type        = number
  default     = 30
}

variable "snapshot_stale" {
  description = "Allow snapshots from a non-leader server (stale reads)."
  type        = bool
  default     = false
}

variable "snapshot_prefix" {
  description = "Filename prefix for snapshot files."
  type        = string
  default     = "nomad"
}

variable "snapshot_max_failures" {
  description = "Number of consecutive failures before the agent gives up leadership."
  type        = number
  default     = 3
}

variable "snapshot_lock_key" {
  description = "Consul KV prefix used to coordinate HA snapshot agents."
  type        = string
  default     = "nomad-snapshot/lock"
}

variable "snapshot_deregister_after" {
  description = "Time after which an unhealthy agent is deregistered from Consul. Set 0 to disable."
  type        = string
  default     = "72h"
}

# ── Storage backend ───────────────────────────────────────────────────────────
# Set storage_backend to one of: local | s3 | azure | gcs

variable "storage_backend" {
  description = "Storage backend for snapshots. One of: local, s3, azure, gcs."
  type        = string
  default     = "local"
}

# Local storage
variable "local_path" {
  description = "Host path to store snapshots when storage_backend = local."
  type        = string
  default     = "/opt/nomad/snapshots"
}

# AWS S3 storage
variable "aws_access_key_id" {
  description = "AWS access key ID. Can also be set via AWS_ACCESS_KEY_ID env or instance role."
  type        = string
  default     = ""
}

variable "aws_secret_access_key" {
  description = "AWS secret access key. Can also be set via AWS_SECRET_ACCESS_KEY env or instance role."
  type        = string
  default     = ""
}

variable "aws_session_token" {
  description = "AWS secret access key. Can also be set via AWS_SECRET_ACCESS_KEY env or instance role."
  type        = string
  default     = ""
}

variable "aws_s3_bucket" {
  description = "S3 bucket name. Required when storage_backend = s3."
  type        = string
  default     = ""
}

variable "aws_s3_region" {
  description = "AWS region for the S3 bucket. Required when storage_backend = s3."
  type        = string
  default     = ""
}

variable "aws_s3_key_prefix" {
  description = "Key prefix for snapshot files in S3."
  type        = string
  default     = "nomad-snapshot"
}

variable "aws_s3_endpoint" {
  description = "Optional S3-compatible endpoint (e.g. MinIO). Leave empty to use AWS default."
  type        = string
  default     = ""
}

variable "aws_s3_server_side_encryption" {
  description = "Enable AES-256 server-side encryption for S3 snapshots."
  type        = bool
  default     = false
}

variable "aws_s3_enable_kms" {
  description = "Enable KMS encryption for S3 snapshots."
  type        = bool
  default     = false
}

variable "aws_s3_kms_key" {
  description = "KMS key ID to use. Leave empty to use the default KMS key."
  type        = string
  default     = ""
}

# Azure Blob storage
variable "azure_account_name" {
  description = "Azure storage account name. Required when storage_backend = azure."
  type        = string
  default     = ""
}

variable "azure_account_key" {
  description = "Azure storage account key. Required when storage_backend = azure."
  type        = string
  default     = ""
}

variable "azure_container_name" {
  description = "Azure Blob container name. Required when storage_backend = azure."
  type        = string
  default     = ""
}

variable "azure_environment" {
  description = "Azure environment. One of: AZUREPUBLICCLOUD, AZURECHINACLOUD, AZUREGERMANCLOUD, AZUREUSGOVERNMENTCLOUD."
  type        = string
  default     = "AZUREPUBLICCLOUD"
}

# Google Cloud Storage
variable "gcs_bucket" {
  description = "GCS bucket name. Required when storage_backend = gcs."
  type        = string
  default     = ""
}

# ── Logging ───────────────────────────────────────────────────────────────────

variable "log_level" {
  description = "Snapshot agent log level. One of: TRACE, DEBUG, INFO, WARN, ERR."
  type        = string
  default     = "INFO"
}

variable "log_json" {
  description = "Output snapshot agent logs in JSON format."
  type        = bool
  default     = false
}

variable "syslog_enabled" {
  description = "Forward snapshot agent logs to syslog."
  type        = bool
  default     = false
}

variable "syslog_facility" {
  description = "Syslog facility to use when syslog_enabled = true."
  type        = string
  default     = "LOCAL0"
}

# ── Resources ─────────────────────────────────────────────────────────────────

variable "cpu" {
  description = "CPU in MHz for the snapshot agent task."
  type        = number
  default     = 200
}

variable "memory" {
  description = "Memory in MB for the snapshot agent task."
  type        = number
  default     = 128
}

variable "memory_max" {
  description = "Memory oversubscription ceiling in MB. Set 0 to disable."
  type        = number
  default     = 256
}

# ── Update & restart ──────────────────────────────────────────────────────────

variable "restart_attempts" {
  description = "Restart attempts within restart_interval before marking failed."
  type        = number
  default     = 3
}

variable "restart_interval" {
  description = "Time window for restart attempts."
  type        = string
  default     = "10m"
}

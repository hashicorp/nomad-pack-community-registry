# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

[[ define "snapshot_agent_config" ]]
nomad {
  address = "[[ var "nomad_addr" . ]]"
  [[ if ne (var "nomad_region" .) "" ]]
  region  = "[[ var "nomad_region" . ]]"
  [[ end ]]
  [[ if ne (var "nomad_token" .) "" ]]
  token   = "[[ var "nomad_token" . ]]"
  [[ end ]]
  [[ if var "tls_enabled" . ]]
  ca_file   = "[[ var "tls_ca_file" . ]]"
  cert_file = "[[ var "tls_cert_file" . ]]"
  key_file  = "[[ var "tls_key_file" . ]]"
  [[ if ne (var "tls_server_name" .) "" ]]
  tls_server_name = "[[ var "tls_server_name" . ]]"
  [[ end ]]
  [[ end ]]
}

snapshot {
  interval         = "[[ var "snapshot_interval" . ]]"
  retain           = [[ var "snapshot_retain" . ]]
  stale            = [[ var "snapshot_stale" . ]]
  prefix           = "[[ var "snapshot_prefix" . ]]"
  lock_key         = "[[ var "snapshot_lock_key" . ]]"
  max_failures     = [[ var "snapshot_max_failures" . ]]
  deregister_after = "[[ var "snapshot_deregister_after" . ]]"
}

log {
  level           = "[[ var "log_level" . ]]"
  enable_syslog   = [[ var "syslog_enabled" . ]]
  syslog_facility = "[[ var "syslog_facility" . ]]"
}

[[ if eq (var "storage_backend" .) "local" ]]
# ── Local storage ─────────────────────────────────────────────────────────────
# raw_exec writes directly to this host path. Ensure the directory
# exists and is writable by the Nomad client process.
local_storage {
  path = "[[ var "local_path" . ]]"
}
[[ end ]]

[[ if eq (var "storage_backend" .) "s3" ]]
# ── AWS S3 / S3-compatible storage ────────────────────────────────────────────
# Credentials resolution order (if access_key_id is left empty):
#   1. AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY / AWS_SESSION_TOKEN env vars
#   2. ~/.aws/credentials file
#   3. ECS task role metadata
#   4. EC2 instance role metadata  ← recommended for AWS-hosted Nomad clusters
aws_storage {
  [[ if ne (var "aws_access_key_id" .) "" ]]
  access_key_id     = "[[ var "aws_access_key_id" . ]]"
  secret_access_key = "[[ var "aws_secret_access_key" . ]]"
  session_token     = "[[ var "aws_session_token" . ]]"
  [[ end ]]
  s3_region         = "[[ var "aws_s3_region" . ]]"
  s3_bucket         = "[[ var "aws_s3_bucket" . ]]"
  s3_key_prefix     = "[[ var "aws_s3_key_prefix" . ]]"
  [[ if ne (var "aws_s3_endpoint" .) "" ]]
  s3_endpoint       = "[[ var "aws_s3_endpoint" . ]]"
  [[ end ]]
  [[ if var "aws_s3_server_side_encryption" . ]]
  s3_server_side_encryption = true
  [[ end ]]
  [[ if var "aws_s3_enable_kms" . ]]
  s3_enable_kms = true
  [[ if ne (var "aws_s3_kms_key" .) "" ]]
  s3_kms_key    = "[[ var "aws_s3_kms_key" . ]]"
  [[ end ]]
  [[ end ]]
}
[[ end ]]

[[ if eq (var "storage_backend" .) "azure" ]]
# ── Azure Blob Storage ────────────────────────────────────────────────────────
# account_name and account_key are required. There is no instance-identity
# fallback for Azure in the snapshot agent — credentials must be explicit.
azure_blob_storage {
  account_name   = "[[ var "azure_account_name" . ]]"
  account_key    = "[[ var "azure_account_key" . ]]"
  container_name = "[[ var "azure_container_name" . ]]"
  environment    = "[[ var "azure_environment" . ]]"
}
[[ end ]]

[[ if eq (var "storage_backend" .) "gcs" ]]
# ── Google Cloud Storage ──────────────────────────────────────────────────────
# Credentials resolution order (no explicit creds in config):
#   1. GOOGLE_APPLICATION_CREDENTIALS env var → path to service account JSON
#   2. GCE instance service account (metadata server) ← recommended for
#      GCP-hosted Nomad clusters
google_storage {
  bucket = "[[ var "gcs_bucket" . ]]"
}
[[ end ]]
[[ end ]]

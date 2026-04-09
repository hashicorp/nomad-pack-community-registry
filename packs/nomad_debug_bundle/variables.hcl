# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# packs/nomad_debug_bundle/variables.hcl

variable "job_name" {
  description = "Name of the Nomad periodic job."
  type        = string
  default     = "nomad-debug-bundle"
}

variable "datacenters" {
  description = "Datacenters where the job is eligible to run."
  type        = list(string)
  default     = ["dc1"]
}

variable "region" {
  description = "Nomad region for the job."
  type        = string
  default     = "global"
}

variable "cron_schedule" {
  description = "Cron expression for how often to collect debug bundles. Default = every 12 hours."
  type        = string
  default     = "0 */12 * * *"
}

variable "prohibit_overlap" {
  description = "Prevent a new periodic run starting if a previous one is still running."
  type        = bool
  default     = true
}

variable "debug_duration" {
  description = "How long 'nomad operator debug' captures logs (e.g. 2m, 5m)."
  type        = string
  default     = "1m"
}

variable "debug_interval" {
  description = "Snapshot interval inside the debug capture (e.g. 30s, 1m)."
  type        = string
  default     = "20s"
}

variable "server_id" {
  description = "Comma-separated server IDs to include. Use 'all' for all servers."
  type        = string
  default     = "all"
}

variable "node_id" {
  description = "Comma-separated client node IDs to include. Use 'all' for all nodes."
  type        = string
  default     = "all"
}

variable "max_nodes" {
  description = "Maximum number of client nodes captured per run."
  type        = number
  default     = 10
}

variable "output_dir" {
  description = "Absolute path on the HOST where debug archives are saved."
  type        = string
  default     = "/opt/nomad/debug-bundles"
}

variable "nomad_addr" {
  description = "Nomad server HTTP address."
  type        = string
  default     = "http://127.0.0.1:4646"
}

variable "nomad_token" {
  description = "Nomad ACL token (leave empty if ACLs are disabled)."
  type        = string
  default     = ""
}

variable "nomad_binary" {
  description = "Path to the nomad binary on the host."
  type        = string
  default     = "/usr/local/bin/nomad" ## Chnage the path as per the nomad binary location
}

variable "retention_days" {
  description = "Number of days to keep debug archives before auto-deletion. Set 0 to disable cleanup."
  type        = number
  default     = 7
}

variable "cpu" {
  description = "CPU in MHz to allocate for the task."
  type        = number
  default     = 200
}

variable "memory" {
  description = "Memory in MB to allocate for the task."
  type        = number
  default     = 128
}

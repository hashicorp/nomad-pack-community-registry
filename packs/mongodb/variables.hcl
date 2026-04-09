# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "job_name" {
  description = "Name of the Nomad job."
  type        = string
  default     = "mongodb"
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

# ── Image ────────────────────────────────────────────────────────────────────

variable "mongo_image" {
  description = "MongoDB Docker image to use."
  type        = string
  default     = "mongo"
}

variable "mongo_image_tag" {
  description = "MongoDB Docker image tag / version."
  type        = string
  default     = "7.0"
}

# ── Authentication ────────────────────────────────────────────────────────────

variable "auth_enabled" {
  description = "Enable MongoDB authentication (--auth flag). Strongly recommended for production."
  type        = bool
  default     = true
}

variable "root_username" {
  description = "MongoDB root username. Only used when auth_enabled = true."
  type        = string
  default     = "admin"
}

variable "root_password" {
  description = "MongoDB root password. Only used when auth_enabled = true. Override this — do not use the default in production."
  type        = string
  default     = "changeme"
}

# ── Networking ────────────────────────────────────────────────────────────────

variable "mongo_port" {
  description = "Port MongoDB listens on (both inside container and static host port)."
  type        = number
  default     = 27017
}

variable "bind_ip" {
  description = "IP MongoDB binds to inside the container. Use 0.0.0.0 to allow external connections."
  type        = string
  default     = "0.0.0.0"
}

# ── Storage ───────────────────────────────────────────────────────────────────

variable "use_host_volume" {
  description = "Mount a host volume for persistent data. Set false for ephemeral/dev deployments."
  type        = bool
  default     = true
}

variable "host_volume_name" {
  description = "Name of the Nomad host volume configured on the client node."
  type        = string
  default     = "mongodb-data"
}

variable "data_dir" {
  description = "Path inside the container where MongoDB stores data."
  type        = string
  default     = "/data/db"
}

# ── Resources ─────────────────────────────────────────────────────────────────

variable "cpu" {
  description = "CPU in MHz to allocate."
  type        = number
  default     = 1024
}

variable "memory" {
  description = "Memory in MB to allocate."
  type        = number
  default     = 1024
}

variable "memory_max" {
  description = "Memory oversubscription ceiling in MB (Nomad 1.1+). Set 0 to disable."
  type        = number
  default     = 2048
}

# ── Health check ──────────────────────────────────────────────────────────────

variable "health_check_interval" {
  description = "How often Nomad runs the health check."
  type        = string
  default     = "30s"
}

variable "health_check_timeout" {
  description = "Timeout for each health check attempt."
  type        = string
  default     = "10s"
}

variable "health_check_initial_status" {
  description = "Initial health status before first check runs."
  type        = string
  default     = "passing"
}

# ── Nomad native service registration ────────────────────────────────────────

variable "register_nomad_service" {
  description = "Register MongoDB as a Nomad native service."
  type        = bool
  default     = true
}

variable "nomad_service_name" {
  description = "Nomad service name."
  type        = string
  default     = "mongodb"
}

variable "nomad_service_tags" {
  description = "Tags applied to the Nomad service."
  type        = list(string)
  default     = ["mongodb", "database"]
}

# ── Restart & update ──────────────────────────────────────────────────────────

variable "restart_attempts" {
  description = "Number of restart attempts within restart_interval before the task is marked failed."
  type        = number
  default     = 3
}

variable "restart_interval" {
  description = "Time window for restart attempts."
  type        = string
  default     = "5m"
}

variable "update_max_parallel" {
  description = "Max allocations updated in parallel during a job update."
  type        = number
  default     = 1
}

variable "update_min_healthy_time" {
  description = "Minimum time an allocation must be healthy before the next update step."
  type        = string
  default     = "30s"
}

variable "update_healthy_deadline" {
  description = "Deadline for an allocation to become healthy."
  type        = string
  default     = "5m"
}

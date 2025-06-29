# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

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

variable "resources" {
    description = "Amount of resources to be allocated to Boundary task"
    type        = object({
      cpu    = number
      memory = number
    })
    default     = {
      cpu       = 500
      memory    = 1024
    }
}

variable "postgres_address" {
  description = "Address of Postgres database"
  type        = string
}

variable "postgres_username" {
  description = "Username with which to authenticate to Postgres"
  type        = string
}

variable "postgres_password" {
  description = "Password with which to authenticate to Postgres"
  type        = string
}

variable "docker_privileged" {
  description = "Run Boundary as a privileged Docker container"
  type        = bool
  default     = false
}

variable "docker_cap_add_ipc_lock" {
  description = "Run Boundary container with IPC_LOCK capability"
  type        = bool
  default     = true
}

variable "config_file" {
  description = "Boundary configuration file"
  type        = string
  default     = <<EOH
# This is a default configuration provided for our Docker image. It's meant to
# be a starting point and to help new users get started. It's strongly
# recommended that this configuration is not used outside of demonstrations
# because it uses hard coded AEAD keys.

disable_mlock = true

controller {
  name = "demo-controller"
  description = "A default controller created for demonstration"

  database {
    # This configuration setting requires the user to execute the container with the URL as an env var
    # to connect to the Boundary postgres DB. An example of how this can be done assuming the postgres 
    # database is running as a container and you're using Docker for Mac (replace host.docker.internal with
    # localhost if you're on Linux):
    #
    #    $  docker run -e 'BOUNDARY_POSTGRES_URL=postgresql://postgres:postgres@host.docker.internal:5432/postgres?sslmode=disable' [other options] boundary:[version]
    url = "env://BOUNDARY_POSTGRES_URL"
  }

  public_cluster_addr = "env://HOSTNAME"
}

worker {
  name = "demo-worker"
  description = "A default worker created for demonstration"
}

listener "tcp" {
  address = "0.0.0.0"
  purpose = "api"
  tls_disable = true 
}

listener "tcp" {
  address = "0.0.0.0"
  purpose = "cluster"
  tls_disable   = true 
}

listener "tcp" {
  address = "0.0.0.0"
  purpose       = "proxy"
  tls_disable   = true 
}

# Root KMS configuration block: this is the root key for Boundary
# Use a production KMS such as AWS KMS in production installs
kms "aead" {
  purpose = "root"
  aead_type = "aes-gcm"
  key = "uC8zAQ3sLJ9o0ZlH5lWIgxNZrNn0FiFqYj4802VKLKQ="
  key_id = "global_root"
}

# Worker authorization KMS
# Use a production KMS such as AWS KMS for production installs
# This key is the same key used in the worker configuration
kms "aead" {
  purpose = "worker-auth"
  aead_type = "aes-gcm"
  key = "cOQ9fiszFoxu/c20HbxRQ5E9dyDM6PqMY1GwqVLihsI="
  key_id = "global_worker-auth"
}

# Recovery KMS block: configures the recovery key for Boundary
# Use a production KMS such as AWS KMS for production installs
kms "aead" {
  purpose = "recovery"
  aead_type = "aes-gcm"
  key = "nIRSASgoP91KmaEcg/EAaM4iAkksyB+Lkes0gzrLIRM="
  key_id = "global_recovery"
}
EOH
}

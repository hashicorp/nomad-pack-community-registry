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

variable "cluster_size" {
  description = "The number of RabbitMQ nodes in the cluster"
  type        = number
  default     = 3
}


variable "consul_service_amqp_tags" {
  description = "The tags to for the AMQP port in the consul service catalog"
  type        = list(string)
  default     = ["amqp"]
}

variable "consul_service_management_tags" {
  description = "The tags to for the management UI port in the consul service catalog"
  type        = list(string)
  default     = ["management"]
}


variable "vault_enabled" {
  description = "Use Vault integration"
  type        = bool
  default     = true
}

variable "vault_roles" {
  description = "The vault role(s) to assign to the node"
  type        = list(string)
  default     = ["rabbit"]
}

variable "image" {
  description = "docker container to use"
  type        = string
  default     = "rabbitmq:3.9.10-management-alpine"
}

variable "enabled_plugins" {
  description = "Extra plugins to enable in the cluster. rabbitmq_peer_discovery_consul is always enabled."
  type        = list(string)
  default = [
    "rabbitmq_management",
  ]
}

variable "extra_conf" {
  description = "Extra configuration values for rabbitmq.conf file"
  type        = string
  default     = ""
}

variable "port_amqp" {
  description = "The port to use for AMQP connections.  Set to 0 for random"
  type        = number
  default     = 0
}

variable "port_ui" {
  description = "The port to use for RabbitMQ UI connections.  Set to 0 for random"
  type        = number
  default     = 0
}

variable "port_discovery" {
  description = "The port RabbitMQ uses for node discovery.  Cannot be dynamically assigned."
  type        = number
  default     = 4369
}

variable "port_clustering" {
  description = "The port RabbitMQ uses for clustering.  Cannot be dynamically assigned."
  type        = number
  default     = 25672
}


// ------------------------------------------------------------------------- //
variable "pki_vault_enabled" {
  description = "Use Vault for secrets and PKI"
  type        = bool
  default     = true
}

variable "pki_vault_domain" {
  description = "The domain of the nomad nodes"
  type        = string
  default     = ""
}

variable "pki_vault_secret_path" {
  description = "The full path to issue a certificate for RabbitMQ from"
  type        = string
  default     = "pki/issue/rabbit"
}

// ------------------------------------------------------------------------- //
variable "pki_artifact_ca_cert" {
  description = "Configures an artifact block to pull the ca certificate"
  type = object({
    enabled = bool
    source  = string
    headers = map(string)
    options = map(string)
  })
  default = {
    enabled = false
    source  = "https://localhost/certs/ca.crt"
    headers = {}
    options = {}
  }
}

variable "pki_artifact_node_cert" {
  description = "Configures an artifact block to pull the ca certificate"
  type = object({
    enabled = bool
    source  = string
    headers = map(string)
    options = map(string)
  })
  default = {
    enabled = false
    source  = "https://localhost/certs/rabbit-node.crt"
    headers = {}
    options = {}
  }
}

variable "pki_artifact_node_cert_key" {
  description = "Configures an artifact block to pull the ca certificate"
  type = object({
    enabled = bool
    source  = string
    headers = map(string)
    options = map(string)
  })
  default = {
    enabled = false
    source  = "https://localhost/certs/rabbit-node.key"
    headers = {}
    options = {}
  }
}

// ------------------------------------------------------------------------- //

variable "cookie_static" {
  description = "The shared secret used by RabbitMQ nodes to join the cluster"
  type        = string
  default     = ""
}

variable "cookie_vault" {
  description = "The shared secret used by RabbitMQ nodes to join the cluster"
  type = object({
    enabled = bool
    path    = string
    key     = string
  })
  default = {
    enabled = true
    path    = "secret/data/rabbit/cookie"
    key     = "cookie"
  }
}

// ------------------------------------------------------------------------- //

variable "admin_user_vault_enabled" {
  description = "Use Vault to set the RabbitMQ root username and password"
  type        = bool
  default     = true
}

variable "admin_user_vault_path" {
  description = "The path to the username|password secret in Vault"
  type        = string
  default     = "secret/data/rabbit/admin"
}

variable "admin_user_vault_username_key" {
  description = "The key to read for the username"
  type        = string
  default     = "username"
}

variable "admin_user_vault_password_key" {
  description = "The key to read for the password"
  type        = string
  default     = "password"
}

// ------------------------------------------------------------------------- //

variable "admin_user_static_username" {
  description = "The admin username for the RabbitMQ root user.  Prefer admin_user_vault over this."
  type        = string
  default     = ""
}
variable "admin_user_static_password" {
  description = "The admin password for the RabbitMQ root user.  Prefer admin_user_vault over this."
  type        = string
  default     = ""
}
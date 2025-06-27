# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name"
  type        = string
  default     = "tfe-job"
}

variable "tfe_agent_job_id" {
  description = "The ID of the TFE agent job which overrides using the pack name"
  type        = string
  default     = "tfe-agent-job"
}

variable "tfe_namespace" {
  description = "The namespace for the tfe job to run."
  type        = string
  default     = "terraform-enterprise"
}

variable "tfe_port" {
  description = "Port to be used by TFE."
  type        = number
  default     = 443
}

variable "tfe_group_count" {
  description = "Count of TFE instances to be deployed"
  type        = number
  default     = 1
}

variable "tfe_http_port" {
  description = "HTTP Port to be used by TFE"
  type        = number
  default     = 8080
}

variable "tfe_vault_cluster_port" {
  description = "Vault cluster port to be used by TFE"
  type        = number
  default     = 8201
}

variable "tfe_service_name" {
  description = "The name to be used for TFE service."
  type        = string
  default     = "tfe-service"
}

variable "datacenters" {
  description = "A list of datacenters in the region which are eligible for task placement"
  type        = list(string)
  default     = ["*"]
}

variable "tfe_database_user" {
  description = "The user to be used while connecting to the database by TFE."
  type        = string
  default     = "hashicorp"
}

variable "tfe_database_host" {
  description = "The host of the database to be used by TFE. Also includes the port number."
  type        = string
}

variable "tfe_database_name" {
  description = "The name of the database to be used by TFE"
  type        = string
  default     = "tfe"
}

variable "tfe_database_parameters" {
  description = "The database parameters to be used by TFE while connecting to the database."
  type        = string
  default     = "sslmode=require"
}

variable "tfe_object_storage_type" {
  description = "The object storage type to be used by TFE"
  type        = string
  default     = "s3"
}

variable "tfe_object_storage_s3_bucket" {
  description = "The name of the object storage bucket to be used by TFE"
  type        = string
  default     = "tfe"
}

variable "tfe_object_storage_s3_region" {
  description = "The region of the object storage bucket used by TFE"
  type        = string
  default     = "us-west-2"
}

variable "tfe_object_storage_s3_use_instance_profile" {
  description = "The instance profile setting for accessing the object storage bucket to be used by TFE"
  type        = bool
  default     = false
}

variable "tfe_object_storage_s3_endpoint" {
  description = "The endpoint of the S3 compatible object storage to be used by TFE"
  type        = string
}

variable "tfe_object_storage_s3_access_key_id" {
  description = "The secret key id of the S3 compatible object storage to be used by TFE"
  type        = string
}

variable "tfe_redis_host" {
  description = "The name of the redis host to be used by TFE"
  type        = string
}

variable "tfe_redis_user" {
  description = "The user to be assumed by TFE to connect to redis."
  type        = string
  default     = ""
}

variable "tfe_redis_use_tls" {
  description = "The tls settings for redis to be used by TFE"
  type        = bool
  default     = false
}

variable "tfe_redis_use_auth" {
  description = "The auth settings to be used by redis"
  type        = bool
  default     = false
}

variable "tfe_hostname" {
  description = "The hostname to be used for reaching the deployed TFE instance"
  type        = string
}

variable "tfe_iact_subnets" {
  description = "The IACT subnet values to be used by TFE"
  type        = string
  default     = ""
}

variable "tfe_iact_time_limit" {
  description = "The IACT time limit value to be used by TFE"
  type        = number
  default     = 60
}

variable "tfe_resource_cpu" {
  description = "The CPU resource limits to be used by TFE."
  type        = number
  default     = 750
}

variable "tfe_resource_memory" {
  description = "The memory resource limits to be used by TFE."
  type        = number
  default     = 1024
}

variable "tfe_image" {
  description = "The terraform enterprise image that will be used to deploy TFE"
  type        = string
  default     = "hashicorp/terraform-enterprise:v202408-1"
}

variable "tfe_image_registry_username" {
  description = "The username to be used to fetch the terraform enterprise image from the registry."
  type        = string
  default     = "terraform"
}

variable "tfe_image_server_address" {
  description = "The server address to be used to fetch the terraform enterprise image from the registry."
  type        = string
  default     = "images.releases.hashicorp.com"
}

variable "tfe_agent_namespace" {
  description = "The namespace to be used while deploying the agent job."
  type        = string
  default     = "tfe-agents"
}

variable "tfe_agent_image" {
  description = "The name of the image to be used while deploying the agent job."
  type        = string
  default     = "hashicorp/tfc-agent:latest"
}

variable "tfe_agent_resource_cpu" {
  description = "The CPU resource limits to be used by TFE Agent."
  type        = number
  default     = 750
}

variable "tfe_agent_resource_memory" {
  description = "The memory resource limits to be used by TFE Agent."
  type        = number
  default     = 1024
}

variable "tfe_vault_cluster_address" {
  description = "The address of the Vault cluster to be used."
  type        = string
  default     = "http://$${NOMAD_HOST_ADDR_vault}"
}

variable "tfe_vault_disable_mlock" {
  description = "Disable mlock for internal Vault."
  type        = bool
  default     = true
}

variable "tfe_service_discovery_provider" {
  description = "Specifies the service registration provider to use for service registrations."
  type        = string
  default     = "nomad"
}

variable "health_check_timeout" {
  description = "Specifies the timeout in case health check API of TFE container is not reachable from Nomad."
  type        = string
  default     = "2s"
}

variable "health_check_interval" {
  description = "Specifies the interval at which Nomad will call the health check API for TFE container."
  type        = string
  default     = "5s"
}

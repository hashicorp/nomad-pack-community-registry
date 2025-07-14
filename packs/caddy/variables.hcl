# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "job_name" {
  description = "The name to use as the job name which overrides using the pack name."
  type        = string
  default     = ""
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

variable "namespace" {
  description = "The namespace where the job should be placed."
  type        = string
  default     = "default"
}

variable "constraints" {
  description = "Constraints to apply to the entire job."
  default     = []
  type        = list(object({
    attribute = string
    operator  = string
    value     = string
  }))
}

variable "version_tag" {
  description = "The docker image version. For options, see https://hub.docker.com/_/caddy"
  type        = string
  default     = "2.6.4"
}

variable "admin_port" {
  description = "The HTTP port for Caddy administration API."
  type        = number
  default     = 2019
}

variable "http_port" {
  description = "The Nomad client port that routes HTTP traffic to Caddy."
  type        = number
  default     = 80
}

variable "https_port" {
  description = "The Nomad client port that routes HTTPS traffic to Caddy."
  type        = number
  default     = 443
}

variable "http_healthcheck_path" {
  description = "The HTTP path served by Caddy to call for health checks."
  type        = string
  default     = "/"
}

variable "https_healthcheck_path" {
  description = "The HTTPS path served by Caddy to call for health checks."
  type        = string
  default     = ""
}

variable "resources" {
  description = "The resource to assign to the Caddy system task that runs on every client"

  type = object({
    cpu    = number
    memory = number
  })

  default = {
    cpu    = 200,
    memory = 256
  }
}

variable "caddyfile" {
  description = "The Caddyfile configuration to pass to the task."
  type        = string

  default     = <<EOF
# The Caddyfile is an easy way to configure your Caddy web server.
#
# Unless the file starts with a global options block, the first
# uncommented line is always the address of your site.
#
# To use your own domain name (with automatic HTTPS), first make
# sure your domain's A/AAAA DNS records are properly pointed to
# this machine's public IP, then replace ":80" below with your
# domain name.

:80 {
	# Set this path to your site's directory.
	root * /usr/share/caddy

	# Enable the static file server.
	file_server

	# Another common task is to set up a reverse proxy:
	# reverse_proxy localhost:8080

	# Or serve a PHP site through php-fpm:
	# php_fastcgi localhost:9000
}

# Refer to the Caddy docs for more information:
# https://caddyserver.com/docs/caddyfile
EOF
}

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

variable "namespace" {
  description = "The namespace where the job should be placed."
  type        = string
  default     = "default"
}

variable "consul_service_name" {
  description = "The consul service you wish to load balance"
  type        = string
  default     = "webapp"
}

variable "version_tag" {
  description = "The docker image version. For options, see https://hub.docker.com/_/caddy"
  type        = string
  default     = "2.4.5"
}

variable "http_port" {
  description = "The Nomad client port that routes HTTP traffic to Caddy."
  type        = number
  default     = 8443
}

variable "https_port" {
  description = "The Nomad client port that routes HTTPS traffic to Caddy."
  type        = number
  default     = 8080
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

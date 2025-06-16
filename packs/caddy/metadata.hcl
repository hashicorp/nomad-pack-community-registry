# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://caddyserver.com"
  author = "Matthew Holt"
}

pack {
  name        = "caddy"
  description = "Caddy 2 is a powerful, enterprise-ready, open source web server with automatic HTTPS written in Go. This pack runs it as a Nomad system job for load balancing."
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/caddy"
  version     = "0.1.0"
}

integration {
  identifier = "nomad/hashicorp/caddy"
  name       = "Caddy"
}

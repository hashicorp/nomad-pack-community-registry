# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://traefik.io/"
  author = "Traefik Labs"
}

pack {
  name        = "traefik"
  description = "Traefik is a modern reverse proxy and load balancer. It runs as a Nomad system job."
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/tree/main/traefik"
  version     = "0.2.0"
}

integration {
  identifier = "nomad/hashicorp/traefik"
  name       = "Traefik"
}

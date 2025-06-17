# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://fabiolb.net/"
  author = "Education Networks of America"
}

pack {
  name        = "fabio"
  description = "Fabio is an HTTP and TCP reverse proxy that configures itself with data from Consul and that runs as a Nomad system job."
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/fabio"
  version     = "0.2.0"
}

integration {
  identifier = "nomad/hashicorp/fabio"
  name       = "Fabio"
}

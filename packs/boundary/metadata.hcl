# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://www.boundaryproject.io/"
  author = "HashiCorp"
}

pack {
  name        = "boundary"
  description = "Boundary is an intelligent proxy that creates granular, identity-based access controls for dynamic infrastructure."
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/boundary"
  version     = "0.2.0"
}

integration {
  identifier = "nomad/hashicorp/boundary"
  name       = "Boundary"
}

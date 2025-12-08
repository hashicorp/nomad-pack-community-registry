# Copyright IBM Corp. 2021, 2025
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://backstage.io"
  author = "Backstage community"
}
pack {
  name        = "backstage"
  description = "An open platform for building developer portals"
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/backstage"
  version     = "0.2.1"
}

integration {
  identifier = "nomad/hashicorp/backstage"
  name       = "Backstage"
}

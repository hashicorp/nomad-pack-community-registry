# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://drone.io/"
  author = "Harness"
}

pack {
  name        = "drone"
  description = "Drone is a self-service Continuous Integration platform for busy development teams."
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/tree/main/drone"
  version     = "0.2.0"
}

integration {
  identifier = "nomad/hashicorp/drone"
  name       = "Drone"
}

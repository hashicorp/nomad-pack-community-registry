# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://learn.hashicorp.com/tutorials/nomad/get-started-run?in=nomad/get-started"
  author = "HashiCorp"
}

pack {
  name        = "simple_service"
  description = "This deploys a simple service job to Nomad that runs a docker container."
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/simple_service"
  version     = "0.2.0"
}

integration {
  identifier = "nomad/hashicorp/simple-service"
  name       = "Simple Service"
}

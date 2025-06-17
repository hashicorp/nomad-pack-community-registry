# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://www.nomadproject.io/docs/autoscaling"
  author = "HashiCorp"
}

pack {
  name        = "nomad_autoscaler"
  description = "The Nomad Autoscaler is an autoscaling daemon for Nomad, architectured around plugins to allow for easy extensibility in terms of supported metrics sources, scaling targets and scaling algorithms."
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/tree/main/nomad_autoscaler"
  version     = "0.2.0"
}

integration {
  identifier = "nomad/hashicorp/nomad-autoscaler"
  name       = "Nomad Autoscaler"
}

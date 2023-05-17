# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://vector.dev/"
  author = "Datadog"
}

pack {
  name        = "vector"
  description = "Vector is a high-performance observability data pipeline."
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/tree/main/vector"
  version     = "0.0.1"
}

integration {
  name       = "Vector"
  identifier = "nomad/hashicorp/vector"
}

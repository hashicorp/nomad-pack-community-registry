# Copyright IBM Corp. 2021, 2025
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://vector.dev/"
  author = "Datadog"
}

pack {
  name        = "vector"
  description = "Vector is a high-performance observability data pipeline."
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/tree/main/vector"
  version     = "0.2.1"
}

integration {
  identifier = "nomad/hashicorp/vector"
  name       = "Vector"
}

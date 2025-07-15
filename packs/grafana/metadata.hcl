# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://grafana.com/"
  author = "Grafana"
}

pack {
  name        = "grafana"
  description = "Grafana is a multi-platform open source analytics and interactive visualization web application."
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/grafana"
  version     = "0.2.1"
}

integration {
  identifier = "nomad/hashicorp/grafana"
  name       = "Grafana"
}

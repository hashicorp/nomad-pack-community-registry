# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://grafana.com/docs/promtail/latest/clients/promtail"
  author = "Grafana"
}

pack {
  name        = "promtail"
  description = "Promtail is an agent which ships the contents of local logs to a private Loki instance or Grafana Cloud."
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/promtail"
  version     = "0.2.0"
}

integration {
  identifier = "nomad/hashicorp/promtail"
  name       = "Promtail"
}

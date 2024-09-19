# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://prometheus.io/"
  author = "Prometheus"
}

pack {
  name        = "prometheus"
  description = "Prometheus is used to collect telemetry data and make it queryable."
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/tree/main/prometheus"
  version     = "0.1.0"
}

integration {
  identifier = "nomad/hashicorp/prometheus-pack"
  name       = "Prometheus"
}

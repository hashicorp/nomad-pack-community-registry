# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://prometheus.io/docs/guides/node-exporter/"
  author = "Prometheus"
}

pack {
  name        = "prometheus_node_exporter"
  description = "The Prometheus Node Exporter exposes a wide variety of hardware and kernel related metrics."
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/tree/main/prometheus_node_exporter"
  version     = "0.2.0"
}

integration {
  identifier = "nomad/hashicorp/prometheus-node-exporter"
  name       = "Prometheus Node Exporter"
}

# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://github.com/prometheus/consul_exporter"
  author = "Prometheus"
}

pack {
  name        = "prometheus_consul_exporter"
  description = "The Prometheus Consul Exporter exposes Consul service health to Prometheus."
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/tree/main/prometheus_consul_exporter"
  version     = "0.0.1"
}

integration {
  name       = "Prometheus Consul Exporter"
  identifier = "nomad/hashicorp/prometheus-consul-exporter"
}

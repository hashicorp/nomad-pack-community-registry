# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://github.com/prometheus/snmp_exporter"
  author = "Prometheus"
}

pack {
  name        = "prometheus_snmp_exporter"
  description = "The Prometheus SNMP exporter alows prometheus to collect SNMP data"
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/tree/main/prometheus_snmp_exporter"
  version     = "0.0.1"
}

integration {
  name       = "Prometheus SNMP Exporter"
  identifier = "nomad/hashicorp/prometheus-snmp-exporter"
}

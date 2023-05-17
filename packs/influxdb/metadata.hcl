# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://www.influxdata.com/"
  author = "InfluxDB"
}

pack {
  name        = "influxdb"
  description = "InfluxDB is an open source time series database for recording metrics, events, and analytics."
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/influxdb"
  version     = "0.0.1"
}

integration {
  identifier = "nomad/hashicorp/influxdb"
  name       = "InfluxDB"
}

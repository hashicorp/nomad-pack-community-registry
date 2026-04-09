# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url = "https://developer.hashicorp.com/nomad/commands/operator/debug"
}
pack {
  name        = "nomad_debug_bundle"
  description = "Periodically runs 'nomad operator debug' and saves bundles to a host directory for troubleshooting."
  version     = "0.1.0"
}

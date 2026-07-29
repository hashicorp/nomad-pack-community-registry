# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url = "https://developer.hashicorp.com/nomad/commands/operator/snapshot/agent"
}

pack {
  name        = "nomad_snapshot_agent"
  description = "Deploys the Nomad Enterprise snapshot agent as a long-running service job. Supports local, AWS S3, Azure Blob, and Google Cloud Storage backends — switchable via variables."
  version     = "0.1.0"
}

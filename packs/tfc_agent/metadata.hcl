# Copyright IBM Corp. 2021, 2025
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://www.terraform.io/docs/cloud/agents/index.html"
  author = "HashiCorp"
}

pack {
  name        = "tfc_agent"
  description = "Terraform Cloud Agent"
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/tree/main/tfc_agent"
  version     = "0.2.1"
}

integration {
  identifier = "nomad/hashicorp/tfc-agent"
  name       = "TFC Agent"
}

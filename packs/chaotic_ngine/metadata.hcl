# Copyright IBM Corp. 2021, 2025
# SPDX-License-Identifier: MPL-2.0

app {
  url = "https://github.com/ngine-io/chaotic"
  author = "René Moser (@resmo)"
}

pack {
  name = "chaotic_ngine"
  description = "Chaotic is a fault injection tool which runs periodically as a batch job in Nomad"
  url = "https://github.com/hashicorp/nomad-pack-community-registry/chaotic_ngine"
  version = "0.2.1"
}

integration {
  identifier = "nomad/hashicorp/chaotic-ngine"
  name       = "Chaotic Ngine"
}

app {
  url = "https://nomatron.io"
}

# SPDX-License-Identifier: MPL-2.0

pack {
  name        = "nomatron"
  description = "Reference architecture for deploying Nomatron on HashiCorp Nomad — production BYODB, Nomatron HA, and lab quickstart profiles."
  version     = "0.2.0"
}

# Optional: vendor the community Traefik pack for advanced customization.
# dependency "traefik" {
#   source = "git::https://github.com/hashicorp/nomad-pack-community-registry.git//packs/traefik"
# }

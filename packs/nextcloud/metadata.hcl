# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://nextcloud.com/"
  author = "Nextcloud GmbH"
}

pack {
  name        = "nextcloud"
  description = "NextCloud"
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/nextcloud"
  version     = "0.0.1"
}

integration {
  name       = "NextCloud"
  identifier = "nomad/hashicorp/nextcloud"
}

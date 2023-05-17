# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://www.getoutline.com/"
  author = "General Outline, Inc. and contributors"
}

pack {
  name        = "outline"
  description = "Outline - Wiki and knowledgebase for teams"
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/outline"
  version     = "0.0.1"
}

integration {
  name       = "Outline"
  identifier = "nomad/hashicorp/outline"
}

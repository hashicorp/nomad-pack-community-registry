# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://wordpress.org/"
  author = "WordPress contributors"
}

pack {
  name        = "wordpress"
  description = "WordPress - Open-source CMS"
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/wordpress"
  version     = "0.0.1"
}

integration {
  name       = "Wordpress"
  identifier = "nomad/hashicorp/wordpress"
}

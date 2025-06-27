# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://github.com/redis/redis"
  author = "Redis"
}

pack {
  name        = "redis"
  description = "Redis - Open-source, networked, in-memory, key-value data store -- STANDALONE INSTANCE"
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/redis"
  version     = "0.2.0"
}

integration {
  identifier = "nomad/hashicorp/redis"
  name       = "Redis"
}

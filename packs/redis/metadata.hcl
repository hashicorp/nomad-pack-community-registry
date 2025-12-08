# Copyright IBM Corp. 2021, 2025
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://github.com/redis/redis"
  author = "Redis"
}

pack {
  name        = "redis"
  description = "Redis - Open-source, networked, in-memory, key-value data store -- STANDALONE INSTANCE"
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/redis"
  version     = "0.2.1"
}

integration {
  identifier = "nomad/hashicorp/redis"
  name       = "Redis"
}

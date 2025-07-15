# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://www.rabbitmq.com"
  author = "VMWare"
}

pack {
  name        = "rabbitmq"
  description = "A RabbitMQ Cluster"
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/rabbitmq"
  version     = "0.2.1"
}

integration {
  identifier = "nomad/hashicorp/rabbitmq"
  name       = "RabbitMQ"
}

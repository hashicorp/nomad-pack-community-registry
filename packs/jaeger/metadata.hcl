# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://www.jaegertracing.io/"
  author = "The Jaeger Authors"
}

pack {
  name        = "jaeger"
  description = "Open source, end-to-end distributed tracing. Monitor and troubleshoot transactions in complex distributed systems"
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/jaeger"
  version     = "0.2.1"
}

integration {
  identifier = "nomad/hashicorp/jaeger"
  name       = "Jaeger"
}

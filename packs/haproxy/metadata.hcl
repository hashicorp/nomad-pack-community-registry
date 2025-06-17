# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url = "https://www.haproxy.org/"
  author = "Willy Tarreau"
}

pack {
  name = "haproxy"
  description = "HAProxy is a free, very fast and reliable solution offering high availability, load balancing, and proxying for TCP and HTTP-based applications. It runs as a Nomad system job."
  url = "https://github.com/hashicorp/nomad-pack-community-registry/haproxy"
  version = "0.2.0"
}

integration {
  identifier = "nomad/hashicorp/haproxy"
  name       = "HAProxy"
}

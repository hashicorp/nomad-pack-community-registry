# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://github.com/ceph/ceph-container"
  author = "Tim Gross <tgross@hashicorp.com>"
}

pack {
  name        = "ceph"
  description = "This pack deploys Ceph in demo mode"
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/ceph"
  version     = "0.2.1"
}

integration {
  identifier = "nomad/hashicorp/ceph"
  name       = "Ceph"
}

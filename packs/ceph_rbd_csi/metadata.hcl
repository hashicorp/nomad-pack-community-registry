# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://github.com/ceph/ceph-csi"
  author = "Tim Gross <tgross@hashicorp.com>"
}

pack {
  name        = "ceph_rbd_csi"
  description = "This pack deploys the Ceph RBD CSI plugin"
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/ceph_rbd_csi"
  version     = "0.1.0"
}

integration {
  identifier = "nomad/hashicorp/ceph-rbd-csi"
  name       = "Ceph RBD CSI"
}

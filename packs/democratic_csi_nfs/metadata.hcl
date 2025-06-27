# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://github.com/democratic-csi/democratic-csi"
  author = "Tim Gross <tgross@hashicorp.com>"
}

pack {
  name        = "democratic_csi_nfs"
  description = "This pack deploys the democratic-csi plugin, configured for use with NFS"
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/democratic_csi_nfs"
  version     = "0.1.0"
}

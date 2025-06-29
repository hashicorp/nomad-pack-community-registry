# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://github.com/kubernetes-sigs/aws-efs-csi-driver"
  author = "Kubernetes SIGs"
}

pack {
  name        = "aws_efs_csi"
  description = "Configures a set of nodes to run the AWS EFS CSI volume plugin."
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/tree/main/aws-efs-csi-driver"
  version     = "0.2.0"
}

integration {
  identifier = "nomad/hashicorp/aws-efs-csi"
  name       = "AWS EFS CSI"
}

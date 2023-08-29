# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://github.com/kubernetes-sigs/aws-ebs-csi-driver"
  author = "Tim Gross <tgross@hashicorp.com>"
}

pack {
  name        = "aws_ebs_csi"
  description = "This pack deploys the AWS EBS CSI plugin"
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/aws_ebs_csi"
  version     = "0.1.0"
}

integration {
  identifier = "nomad/hashicorp/aws-ebs-csi"
  name       = "AWS EBS CSI"
}

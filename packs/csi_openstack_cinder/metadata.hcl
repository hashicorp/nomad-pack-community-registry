# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url = "https://github.com/kubernetes/cloud-provider-openstack/blob/master/docs/cinder-csi-plugin/using-cinder-csi-plugin.md"
  author = "Kubernetes"
}

pack {
  name = "csi_openstack_cinder"
  description = "The Cinder CSI Driver is a CSI Specification compliant driver used by Container Orchestrators to manage the lifecycle of OpenStack Cinder Volumes."
  url = "https://github.com/hashicorp/nomad-pack-community-registry/tree/main/packs/csi_openstack_cinder"
  version = "0.2.0"
}

integration {
  identifier = "nomad/hashicorp/csi-openstack-cinder"
  name       = "CSI OpenStack Cinder"
}

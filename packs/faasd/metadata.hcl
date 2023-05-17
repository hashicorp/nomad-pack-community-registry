# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://www.openfaas.com"
  author = "Openfaas"
}

pack {
  name        = "faasd"
  description = "Faasd is OpenFaaS reimagined, but without the cost and complexity of Kubernetes."
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/faasd"
  version     = "0.0.1"
}

integration {
  identifier = "nomad/hashicorp/faasd"
  name       = "Faasd"
}

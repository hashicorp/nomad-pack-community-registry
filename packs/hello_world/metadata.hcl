# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url = "https://learn.hashicorp.com/tutorials/nomad/get-started-run?in=nomad/get-started"
  author = "HashiCorp"
}

pack {
  name = "hello_world"
  description = "This deploys a simple applicaton as a service with an optional associated consul service."
  url = "https://github.com/hashicorp/nomad-pack-community-registry/hello_world"
  version = "0.0.1"
}

integration {
  identifier = "nomad/hashicorp/hello-world"
  name       = "Hello World"
}

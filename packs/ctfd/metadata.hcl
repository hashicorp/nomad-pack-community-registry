# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://ctfd.io/"
  author = "CTFd"
}

pack {
  name        = "ctfd"
  description = "The open source Capture The Flag framework for hiring, training, and teaching hackers"
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/ctfd"
  version     = "0.2.1"
}

integration {
  identifier = "nomad/hashicorp/ctfd"
  name       = "CTFd"
}

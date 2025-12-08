# Copyright IBM Corp. 2021, 2025
# SPDX-License-Identifier: MPL-2.0

app {
  url    = "https://www.jenkins.io/"
  author = "CloudBees"
}

pack {
  name        = "jenkins"
  description = "Jenkins is an open source automation server which enables developers around the world to reliably build, test, and deploy their software."
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/jenkins"
  version     = "0.2.1"
}

integration {
  identifier = "nomad/hashicorp/jenkins"
  name       = "Jenkins"
}

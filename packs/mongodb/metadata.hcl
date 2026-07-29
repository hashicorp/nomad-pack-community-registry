# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url = "https://www.mongodb.com/docs/manual/"
}

pack {
  name        = "mongodb"
  description = "Deploys a MongoDB instance on Nomad with persistent host volume storage, configurable authentication, and optional resource limits."
  version     = "0.1.0"
}

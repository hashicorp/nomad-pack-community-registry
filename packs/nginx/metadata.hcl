# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

app {
  url = "https://www.nginx.com/"
  author = "F5 Networks"
}

pack {
  name = "nginx"
  description = "Nginx is a web server that can also be used as a reverse proxy, load balancer, mail proxy and HTTP cache. This pack runs it runs as a Nomad system job for load balancing."
  url = "https://github.com/hashicorp/nomad-pack-community-registry/nginx"
  version = "0.2.0"
}

integration {
  identifier = "nomad/hashicorp/nginx"
  name       = "Nginx"
}

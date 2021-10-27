app {
  url    = "https://www.nginx.com/"
  author = "F5 Networks"
}

pack {
  name        = "nomad_ingress_nginx"
  description = "Provides ingress capability to Nomad jobs using Nginx as reverse proxy and configured via service tags or meta values."
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/nomad_ingress_nginx"
  version     = "0.0.1"
}

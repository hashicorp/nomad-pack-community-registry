Nomad Ingress Nginx successfully deployed.

Define service meta values or tags to start using it.

    service {
      name = "webapp"
      port = "http"

      tags = [
        "nomad_ingress_enabled=true",
        "nomad_ingress_hostname=webapp.example.com",
      ]
    }

    service {
      name = "webapp"
      port = "http"

      meta {
        nomad_ingress_enabled  = true
        nomad_ingress_hostname = "webapp.example.com"
      }
    }

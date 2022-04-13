job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .grafana.datacenters | toStringList ]]

  // must have linux for network mode
  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  group "grafana" {
    count = 1

    network {
      mode = "bridge"

      port "http" {
        to = [[ .grafana.http_port ]]
      }
    }

    service {
      name = "grafana"
      port = "[[ .grafana.http_port ]]"

      connect {
        sidecar_service {
          proxy {
            [[ range $upstream := .grafana.upstreams ]]
            upstreams {
              destination_name = [[ $upstream.name | quote ]]
              local_bind_port  = [[ $upstream.port ]]
            }
            [[ end ]]
          }
        }
      }
    }

    task "grafana" {
      driver = "docker"

      config {
        image = "grafana/grafana:[[ .grafana.version_tag ]]"
        ports = ["http"]
      }

      resources {
        cpu    = [[ .grafana.resources.cpu ]]
        memory = [[ .grafana.resources.memory ]]
      }
    }
  }
}

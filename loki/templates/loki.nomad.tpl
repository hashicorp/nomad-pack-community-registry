job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [ [[ range $idx, $dc := .loki.datacenters ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]

  // must have linux for network mode
  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  group "loki" {
    count = 1

    network {
      mode = "bridge"

      port "http" {
        to = [[ .loki.http_port ]]
      }
    }

    service {
      name = "loki"
      port = "[[ .loki.http_port ]]"

      connect {
        sidecar_service {}
      }
    }

    task "loki" {
      driver = "docker"

      config {
        image = "grafana/loki:[[ .loki.version_tag ]]"
      }

      resources {
        cpu    = [[ .loki.resources.cpu ]]
        memory = [[ .loki.resources.memory ]]
      }
    }
  }
}

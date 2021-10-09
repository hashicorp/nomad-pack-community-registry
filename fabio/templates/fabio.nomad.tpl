job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [ [[ range $idx, $dc := .fabio.datacenters ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]

  type = "system"

  // must have linux for network mode
  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  group "fabio" {
    network {
      port "lb" {
        static = [[ .fabio.http_port ]]
      }
      port "ui" {
        static = [[ .fabio.ui_port ]]
      }
    }

    task "fabio" {
      driver = "docker"
      config {
        image        = "fabiolb/fabio"
        network_mode = "host"
        ports        = ["lb", "ui"]
      }

      resources {
        cpu    = [[ .fabio.resources.cpu ]]
        memory = [[ .fabio.resources.memory ]]
      }
    }
  }
}

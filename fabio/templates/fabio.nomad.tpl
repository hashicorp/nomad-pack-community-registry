job "fabio" {
  region      = [[ .fabio.region | quote]]
  datacenters = [ [[ range $idx, $dc := .fabio.datacenters ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]

  type = "system"

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
        image = "fabiolb/fabio"
        network_mode = "host"
        ports = ["lb","ui"]
      }

      resources {
        cpu    = [[ .fabio.resources.cpu ]]
        memory = [[ .fabio.resources.memory ]]
      }
    }
  }
}

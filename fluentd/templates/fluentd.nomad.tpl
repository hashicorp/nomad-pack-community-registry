job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [ [[ range $idx, $dc := .nginx.datacenters ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]

  type = "service"

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  update {
    stagger = "10s"
    max_parallel = 1
  }

  group "fluentd" {
    count = 1

    network {
      port "http" {
        static = [[ .fluentd.http_port ]]
      }
    }

    service {
      name = "fluentd"
      port = "http"

      tags = [
    "monitoring",
              "traefik.tags=pink,lolcats",
              "traefik.frontend.rule=Host:fluentd.local"
]
    }

    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    ephemeral_disk {
      sticky = true
      migrate = true
      size = 3000
    }

    task "fluentd" {
      # The "driver" parameter specifies the task driver that should be used to
      # run the task.
      driver = "docker"

      config {
        image = "fluent/fluentd:[[ .fluentd.version_tag ]]"
        ports = ["fluentd"]
      }

      resources {
        cpu    = [[ .fluentd.resources.cpu ]]
        memory = [[ .fluentd.resources.memory ]]
        network {
          mbits = [[ .fluentd.resources.network_mbits ]]
          port "fluentd" {}
        }
      }
    }
  }
}
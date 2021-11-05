job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .loki.datacenters | toPrettyJson ]]

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

      port "grpc" {
        to = [[ .loki.grpc_port ]]
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
        [[- if ne .loki.loki_yaml "" ]]
        args = [
          "--config.file=/etc/loki/config/loki.yml",
        ]
        volumes = [
          "local/config:/etc/loki/config",
        ]
        [[- end ]]
      }

      resources {
        cpu    = [[ .loki.resources.cpu ]]
        memory = [[ .loki.resources.memory ]]
      }

      [[- if ne .loki.loki_yaml "" ]]
      template {
        data = <<EOH
[[ .loki.loki_yaml ]]
EOH
        change_mode   = "signal"
        change_signal = "SIGHUP"
        destination   = "local/config/loki.yml"
      }
      [[- end ]]
    }
  }
}

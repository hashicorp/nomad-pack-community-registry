job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ var "datacenters" . | toStringList ]]

  [[ if var "constraints" . ]][[ range $idx, $constraint := var "constraints" . ]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    value     = [[ $constraint.value | quote ]]
    [[- if ne $constraint.operator "" ]]
    operator  = [[ $constraint.operator | quote ]]
    [[- end ]]
  }
  [[- end ]][[- end ]]

  group "loki" {
    count = 1

    network {
      mode = "bridge"

      port "http" {
        to = [[ var "http_port" . ]]
      }

      port "grpc" {
        to = [[ var "grpc_port" . ]]
      }
    }

    service {
      name = "loki"
      port = "[[ var "http_port" . ]]"

      connect {
        sidecar_service {}
      }
    }

    task "loki" {
      driver = "docker"

      config {
        image = "grafana/loki:[[ var "version_tag" . ]]"
        [[- if ne (var "loki_yaml" .) "" ]]
        args = [
          "--config.file=/etc/loki/config/loki.yml",
        ]
        volumes = [
          "local/config:/etc/loki/config",
          [[- if ne (var "rules_yaml" .) "" ]]
          "local/rules:/etc/loki/rules/default",
          [[- end ]]
        ]
        [[- end ]]
      }

      resources {
        cpu    = [[ var "resources.cpu" . ]]
        memory = [[ var "resources.memory" . ]]
      }

      [[- if ne (var "loki_yaml" .) "" ]]
      template {
        data = <<EOH
[[ var "loki_yaml" . ]]
EOH
        change_mode   = "signal"
        change_signal = "SIGHUP"
        destination   = "local/config/loki.yml"
      }
      [[- end ]]

      [[- if ne (var "rules_yaml" .) "" ]]
      template {
        data = <<EOH
[[ var "rules_yaml" . ]]
EOH
        change_mode   = "signal"
        change_signal = "SIGHUP"
        destination   = "local/rules/rules.yaml"
      }
      [[- end ]]
    }
  }
}

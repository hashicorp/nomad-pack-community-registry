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

  group "tempo" {
    count = 1

    network {
      mode = "bridge"

      port "grpc" {
        to = [[ var "grpc_port" . ]]
      }
      port "http" {
        to = [[ var "http_port" . ]]
      }
      port "jaeger_thrift_compact" {
        to = 6831
        static = 6831
      }
      port "jaeger_thrift_binary" {
        to = 6832
        static = 6832
      }
      port "jaeger_thrift_http" {
        to = 14268
        static = 14268
      }
      port "jaeger_grpc" {
        to = 14250
        static = 14250
      }
      port "otlp_grpc" {
        to = 55680
        static = 55680
      }
      port "otlp_http" {
        to = 55681
        static = 55681
      }
      port "opencensus" {
        to = 55678
        static = 55678
      }
      port "zipkin" {
        to = 9411
        static = 9411
      }
    }

    [[ if var "register_consul_service" . ]]
    service {
      name = "[[ var "consul_service_name" . ]]"
      tags = [[ var "consul_service_tags" . | toStringList ]]
      port = "[[ var "http_port" . ]]"
      [[ if var "register_consul_service" . ]]
      connect {
        sidecar_service {}
      }
      [[ end ]]
    }
    [[ end ]]

    task "tempo" {
      driver = "docker"

      config {
        image = "grafana/tempo:[[ var "version_tag" . ]]"
        [[- if ne (var "tempo_yaml" .) "" ]]
        args = [
          "--config.file=/etc/tempo/config/tempo.yml",
        ]
        volumes = [
          "local/config:/etc/tempo/config",
        ]
        [[- end ]]
      }

      resources {
        cpu    = [[ var "resources.cpu" . ]]
        memory = [[ var "resources.memory" . ]]
      }

      [[- if ne (var "tempo_yaml" .) "" ]]
      template {
        data = <<EOH
[[ var "tempo_yaml" . ]]
EOH

        change_mode   = "signal"
        change_signal = "SIGHUP"
        destination   = "local/config/tempo.yml"
      }
[[- end ]]
    }
  }
}

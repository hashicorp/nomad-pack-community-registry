job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .tempo.datacenters | toStringList ]]

  [[ if .tempo.constraints ]][[ range $idx, $constraint := .tempo.constraints ]]
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
        to = [[ .tempo.grpc_port ]]
      }
      port "http" {
        to = [[ .tempo.http_port ]]
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

    [[ if .tempo.register_consul_service ]]
    service {
      name = "[[ .tempo.consul_service_name ]]"
      tags = [[ .tempo.consul_service_tags | toStringList ]]
      port = "[[ .tempo.http_port ]]"
      [[ if .tempo.register_consul_service ]]
      connect {
        sidecar_service {}
      }
      [[ end ]]
    }
    [[ end ]]

    task "tempo" {
      driver = "docker"

      config {
        image = "grafana/tempo:[[ .tempo.version_tag ]]"
        [[- if ne .tempo.tempo_yaml "" ]]
        args = [
          "--config.file=/etc/tempo/config/tempo.yml",
        ]
        volumes = [
          "local/config:/etc/tempo/config",
        ]
        [[- end ]]
      }

      resources {
        cpu    = [[ .tempo.resources.cpu ]]
        memory = [[ .tempo.resources.memory ]]
      }

      [[- if ne .tempo.tempo_yaml "" ]]
      template {
        data = <<EOH
[[ .tempo.tempo_yaml ]]
EOH

        change_mode   = "signal"
        change_signal = "SIGHUP"
        destination   = "local/config/tempo.yml"
      }
[[- end ]]
    }
  }
}

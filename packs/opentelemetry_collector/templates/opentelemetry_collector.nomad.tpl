job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .opentelemetry_collector.datacenters | toPrettyJson ]]

  // must have linux for network mode
  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  group "opentelemetry_collector" {
    count = 1

    network {
      port "otlp" {
        static = [[ .opentelemetry_collector.otlp_port ]]
      }
    }

    service {
      name = "opentelemetry-collector"
      port = "otlp"
    }

    task "opentelemetry_collector" {
      driver = "docker"

      config {
        image   = "[[ .opentelemetry_collector.container_registry ]][[ .opentelemetry_collector.container_image_name ]]:[[ .opentelemetry_collector.container_version_tag ]]"
        args    = [ "--config", "/etc/otel/config.yaml" ]
        ports   = [ "otlp" ]
        volumes = [ "local:/etc/otel" ]
      }

      template {
        data          = <<-EOF
          receivers:
            otlp:
              protocols:
                grpc:
                http:

          processors:
            batch:

          exporters:
            otlp:
              endpoint: localhost:4317

          extensions:
            health_check:
            pprof:
            zpages:

          service:
            extensions: [health_check,pprof,zpages]
            pipelines:
              traces:
                receivers: [otlp]
                processors: [batch]
                exporters: [otlp]
              metrics:
                receivers: [otlp]
                processors: [batch]
                exporters: [otlp]
              logs:
                receivers: [otlp]
                processors: [batch]
                exporters: [otlp]
        EOF
        destination   = "local/config.yaml"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      resources {
        cpu    = [[ .opentelemetry_collector.resources.cpu ]]
        memory = [[ .opentelemetry_collector.resources.memory ]]
      }
    }
  }
}

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
      port "metrics" {
        to = 8888
      }

      # Receivers
      port "otlp" {
        to = 4317
      }

      port "jaeger-grpc" {
        to = 14250
      }

      port "jaeger-thrift-http" {
        to = 14268
      }

      port "zipkin" {
        to = 9411
      }

      # Extensions
      port "health-check" {
        to = 13133
      }

      port "zpages" {
        to = 55679
      }
    }

    service {
      name = "otel-collector"
      port = "health-check"
      tags = ["health"]

      check {
        type     = "http"
        port     = "health-check"
        path     = "/"
        interval = "5s"
        timeout  = "2s"
      }
    }

    service {
      name = "otel-collector"
      port = "otlp"
      tags = ["otlp"]
    }

    service {
      name = "otel-collector"
      port = "jaeger-grpc"
      tags = ["jaeger-grpc"]
    }

    service {
      name = "otel-collector"
      port = "jaeger-thrift-http"
      tags = ["jaeger-thrift-http"]
    }

    service {
      name = "otel-collector"
      port = "zipkin"
      tags = ["zipkin"]
    }

    service {
      name = "otel-agent"
      port = "metrics"
      tags = ["metrics"]
    }

    service {
      name = "otel-agent"
      port = "zpages"
      tags = ["zpages"]
    }

    task "opentelemetry_collector" {
      driver = "docker"

      config {
        image   = "[[ .opentelemetry_collector.container_registry ]][[ .opentelemetry_collector.container_image_name ]]:[[ .opentelemetry_collector.container_version_tag ]]"
        args    = [ "--config=/etc/otel/config.yaml" ]
        ports   = [ "metrics", "otlp", "jaeger-grpc", "jaeger-thrift-http", "zipkin", "health-check", "zpages",]
        volumes = [ "local:/etc/otel" ]
      }

      template {
        destination = "local/config.yaml"
        data        = <<-EOF
          ---
          receivers:
            otlp:
              protocols:
                grpc:
                http:
            jaeger:
              protocols:
                grpc:
                thrift_http:
            zipkin: {}

          processors:
            batch:
            memory_limiter:
              # Same as --mem-ballast-size-mib CLI argument
              ballast_size_mib: 683
              # 80% of maximum memory up to 2G
              limit_mib: 1500
              # 25% of limit up to 2G
              spike_limit_mib: 512
              check_interval: 5s

          extensions:
            health_check: {}
            zpages: {}

          exporters:
            prometheus:
              endpoint: "localhost:8889"
              namespace: "default"

          service:
            extensions: [health_check, zpages]
            pipelines:
              metrics:
                receivers: [otlp]
                exporters: [prometheus]
          EOF
      }

      resources {
        cpu    = [[ .opentelemetry_collector.resources.cpu ]]
        memory = [[ .opentelemetry_collector.resources.memory ]]
      }
    }
  }
}

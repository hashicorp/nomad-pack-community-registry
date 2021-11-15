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
      [[ template "network_ports" . ]]
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
[[ .opentelemetry_collector.config_yaml ]]
        EOF
      }

      resources {
        cpu    = [[ .opentelemetry_collector.resources.cpu ]]
        memory = [[ .opentelemetry_collector.resources.memory ]]
      }
    }
  }
}

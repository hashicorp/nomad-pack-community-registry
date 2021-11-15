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

    [[ template "services" . ]]

    task "opentelemetry_collector" {
      driver = "docker"

      template {
        destination = "local/config.yaml"
        data        = <<-EOF
[[ .opentelemetry_collector.config_yaml ]]
        EOF
      }

      config {
        image   = "[[ .opentelemetry_collector.container_registry ]][[ .opentelemetry_collector.container_image_name ]]:[[ .opentelemetry_collector.container_version_tag ]]"
        args    = [ "--config=/etc/otel/config.yaml" ]
        ports   = [[ template "container_ports" . ]]
        volumes = [ "local:/etc/otel" ]
      }

      resources {
        cpu    = [[ .opentelemetry_collector.resources.cpu ]]
        memory = [[ .opentelemetry_collector.resources.memory ]]
      }
    }
  }
}

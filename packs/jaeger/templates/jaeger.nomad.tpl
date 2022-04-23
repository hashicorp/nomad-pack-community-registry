job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .jaeger.datacenters | toPrettyJson ]]

  // must have linux for network mode
  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  group "jaeger" {
    count = 1

    network {
      port "http_ui" {
        to = [[ .jaeger.http_ui_port ]]
      }
      port "http_collector" {
        to = [[ .jaeger.http_collector_port ]]
      }
    }

    service {
      name = "jaeger"
      port = "[[ .jaeger.http_ui_port ]]"

    }

    task "jaeger" {
      driver = "docker"

      config {
        image = "jaegertracing/all-in-one:[[ .jaeger.version_tag ]]"
        ports = ["http_ui", "http_collector"]
      }

      env {
           SPAN_STORAGE_TYPE = "memory"
      }

      resources {
        cpu    = [[ .jaeger.resources.cpu ]]
        memory = [[ .jaeger.resources.memory ]]
      }
    }
  }
}

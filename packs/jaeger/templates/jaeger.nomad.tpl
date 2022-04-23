job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .my.datacenters | toStringList ]]

  group "jaeger" {
    count = 1

    network {
      port "http_ui" {
        to = [[ .my.http_ui_port ]]
      }
      port "http_collector" {
        to = [[ .my.http_collector_port ]]
      }
    }

    service {
      name = "jaeger"
      port = "[[ .my.http_ui_port ]]"
    }

    task "jaeger" {
      driver = "docker"

      config {
        image = "jaegertracing/all-in-one:[[ .my.version_tag ]]"
        ports = ["http_ui", "http_collector"]
      }

      env {
        SPAN_STORAGE_TYPE = "memory"
      }

      resources {
        cpu    = [[ .my.resources.cpu ]]
        memory = [[ .my.resources.memory ]]
      }
    }
  }
}

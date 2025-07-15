job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ var "datacenters" . | toStringList ]]
  node_pool   = [[ var "node_pool" . | quote ]]

  group "jaeger" {
    count = 1

    network {
      port "http_ui" {
        to = [[ var "http_ui_port" . ]]
      }
      port "http_collector" {
        to = [[ var "http_collector_port" . ]]
      }
    }

    service {
      name = "jaeger"
      port = "[[ var "http_ui_port" . ]]"
    }

    task "jaeger" {
      driver = "docker"

      config {
        image = "jaegertracing/all-in-one:[[ var "version_tag" . ]]"
        ports = ["http_ui", "http_collector"]
      }

      env {
        SPAN_STORAGE_TYPE = "memory"
      }

      resources {
        cpu    = [[ var "resources.cpu" . ]]
        memory = [[ var "resources.memory" . ]]
      }
    }
  }
}

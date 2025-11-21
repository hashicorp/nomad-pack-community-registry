# OpenTelemetry Collector Job
job "[[ var "release_name" . ]]_otel_collector" {

  [[ template "header" . ]]

  group "signoz-otel-collector" {
    count = [[ var "otel_collector_count" . ]]

    network {
      mode = "bridge"
      port "metrics" { to = [[ var "otel_collector_metrics_port" . ]] }
      port "otlp" { static = [[ var "otel_collector_otlp_port" . ]] }
      port "otlp_http" { static = [[ var "otel_collector_otlp_http_port" . ]] }
      port "health" { to = [[ var "otel_collector_health_port" . ]] }
    }

    task "collector" {
      driver = "docker"

      template {
        destination   = "/local/otel-collector-config.yaml"
        perms         = "0644"
        change_mode   = "signal"
        change_signal = "SIGHUP"
        data          = file("[[ var "config" .]]/signoz/otel-collector-config.yaml")
      }

      template {
        data        = <<EOF
{{range service "signoz-opamp"}}
server_endpoint: ws://{{.Address}}:{{.Port}}/v1/opamp
{{end}}
    EOF
        destination = "local/otel-collector-opamp-config.yaml"
        change_mode = "restart"
      }

      [[ template "clickhouse_address" . ]]
      [[ template "clickhouse_password" . ]]
      env {
        CLICKHOUSE_CLUSTER = [[ var "clickhouse_cluster_name" . | quote ]]
      }

      config {
        image   = "docker.io/signoz/signoz-otel-collector:[[ var "otel_collector_version" . ]]"
        command = "/signoz-otel-collector"
        args = [
          "--config=/conf/otel-collector-config.yaml",
          "--manager-config=/conf/otel-collector-opamp-config.yaml",
          "--copy-path=/var/tmp/collector-config.yaml",
          "--feature-gates=-pkg.translator.prometheus.NormalizeName",
        ]
        ports = ["metrics","otlp","otlp_http","health"]
        volumes = [
          "local/otel-collector-config.yaml:/conf/otel-collector-config.yaml",
          "local/otel-collector-opamp-config.yaml:/conf/otel-collector-opamp-config.yaml",
        ]
      }

      service {
        name         = "signoz-otel-collector"
        port         = "metrics"
        check {
          name          = "liveness"
          type          = "http"
          path          = "/"
          port          = "health"
          interval      = "10s"
          timeout       = "5s"
          initial_status = "critical"
        }
      }

      resources {
        cpu    = [[ var "otel_collector_cpu" . ]]
        memory = [[ var "otel_collector_memory" . ]]
      }
    }
  }
}

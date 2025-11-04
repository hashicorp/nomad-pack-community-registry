# OpenTelemetry Collector Job
job "[[ var "job_name" . ]]_otel_collector" {
  [[ template "region" . ]]
  datacenters = [[ var "datacenters" . | toStringList ]]
  type = "service"

  group "signoz-otel-collector" {
    count = [[ var "otel_collector_count" . ]]

    network {
      mode = "bridge"
      port "metrics" { static = [[ var "otel_collector_metrics_port" . ]] }
      port "otlp" { static = [[ var "otel_collector_otlp_port" . ]] }
      port "otlp_http" { static = [[ var "otel_collector_otlp_http_port" . ]] }
      port "health" { static = [[ var "otel_collector_health_port" . ]] }
    }

    task "collector" {
      driver = "docker"
      
      template {
        destination   = "/local/otel-collector-config.yaml"
        change_mode   = "signal"
        change_signal = "SIGHUP"
        data          = <<EOT
[[ fileContents "templates/configs/signoz/otel-collector-config.yaml" ]]
        EOT
      }
      
      template {
        destination   = "local/otel-collector-opamp-config.yaml"
        change_mode   = "signal"
        change_signal = "SIGHUP"
        data          = <<-EOT
          server_endpoint: ws://signoz.service.consul:[[ var "signoz_opamp_port" . ]]/v1/opamp
          EOT
      }
      
      template {
        env = true
        data = <<EOH
        {{range service "clickhouse-tcp"}}
        CLICKHOUSE_PORT={{ .Port }}
        CLICKHOUSE_HOST={{ .Address }}
        {{end}}
        EOH
        destination = "secrets/hosts.env"
      }
      
      env {
        CLICKHOUSE_CLUSTER = [[ var "clickhouse_cluster_name" . | quote ]]
        CLICKHOUSE_USER = [[ var "clickhouse_user" . | quote ]]
        CLICKHOUSE_PASSWORD = [[ var "clickhouse_password" . | quote ]]
        CLICKHOUSE_SECURE = [[ var "clickhouse_secure" . | quote ]]
        DOT_METRICS_ENABLED = "true"
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

      service {
        name         = "signoz-otel-collector-otlp"
        port         = "otlp"
        check {
          name         = "tcp-otlp"
          type         = "tcp"
          interval     = "15s"
          timeout      = "3s"
        }
      }
      
      service {
        name         = "signoz-otel-collector-otlp-http"
        port         = "otlp_http"
        check {
          name         = "tcp-otlp-http"
          type         = "tcp"
          interval     = "15s"
          timeout      = "3s"
        }
      }

      resources {
        cpu    = [[ var "otel_collector_cpu" . ]]
        memory = [[ var "otel_collector_memory" . ]]
      }
    }
  }
}

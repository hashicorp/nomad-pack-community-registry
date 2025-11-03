# SigNoz Main Application Job
job "[[ template "job_name" . ]]_signoz"  {
  [[ template "region" . ]]
  datacenters = [[ var "datacenters" . | toStringList ]]
  type = "service"

  group "signoz" {
    count = [[ var "signoz_count" . ]]
    
    network {
      mode = "bridge"
      port "http" { static = [[ var "signoz_http_port" . ]] }
      port "http-internal" { static = [[ var "signoz_internal_port" . ]] }
      port "opamp-internal" { static = [[ var "signoz_opamp_port" . ]] }
    }

    volume "signoz-db" {
      type = "host"
      access_mode = "single-node-single-writer"
      source = [[ var "signoz_volume_name" . | quote ]]
      attachment_mode="file-system"
    }

    # SigNoz initialization task
    task "signoz-init" {
      driver = "docker"
      lifecycle {
        hook = "prestart"
        sidecar = false
      }
      
      env {
        CLICKHOUSE_HOST = "clickhouse.service.consul"
        CLICKHOUSE_HTTP_PORT = [[ var "clickhouse_http_port" . ]]
      }
      
      config {
        image = "docker.io/busybox:1.35"
        command = "sh"
        args = [
          "-c",
          <<-EOT
          echo "Waiting for ClickHouse HTTP ping..."
          until wget -q --spider "http://$${CLICKHOUSE_HOST}:$${CLICKHOUSE_HTTP_PORT}/ping"; do
          echo "waiting for clickhouseDB (HTTP $${CLICKHOUSE_HOST}:$${CLICKHOUSE_HTTP_PORT}/ping)"; sleep 5;
          done
          echo "ClickHouse HTTP is up"
          EOT
        ]
      }
    }

    # Main SigNoz task
    task "signoz" {
      driver = "docker"

      env {
        CLICKHOUSE_HOST = "clickhouse.service.consul"
        CLICKHOUSE_PORT = [[ var "clickhouse_tcp_port" . ]]
        CLICKHOUSE_USER = [[ var "clickhouse_user" . | quote ]]
        CLICKHOUSE_PASSWORD = [[ var "clickhouse_password" . | quote ]]
        SIGNOZ_TELEMETRYSTORE_PROVIDER = "clickhouse"
        SIGNOZ_TELEMETRYSTORE_CLICKHOUSE_DSN = "tcp://$${CLICKHOUSE_USER}:$${{CLICKHOUSE_PASSWORD}@$${CLICKHOUSE_HOST}:$${CLICKHOUSE_PORT}"
        SIGNOZ_TELEMETRYSTORE_CLICKHOUSE_CLUSTER = [[ var "clickhouse_cluster_name" . | quote ]]
      }

      config {
        image = "docker.io/signoz/signoz:[[ var "signoz_version" . ]]"
        ports = ["http", "http-internal", "opamp-internal"]
      }

      volume_mount {
        volume      = "signoz-db"
        destination = "/var/lib/signoz"
        read_only   = false
      }

      resources {
        cpu    = [[ var "signoz_cpu" . ]]
        memory = [[ var "signoz_memory" . ]]
      }

      service {
        name = "signoz"
        port = "http"

        check {
          name     = "http-ping"
          type     = "http"
          path     = "/api/v1/health"
          port     = "http"
          interval = "10s"
          timeout  = "3s"
        }
      }

      service {
        name = "signoz"
        port = "http-internal"

        check {
          name     = "http-internal"
          type     = "tcp"
          port     = "http-internal"
          interval = "10s"
          timeout  = "3s"
        }
      }

      service {
        name = "signoz"
        port = "opamp-internal"

        check {
          name     = "opamp-internal"
          type     = "tcp"
          port     = "opamp-internal"
          interval = "10s"
          timeout  = "3s"
        }
      }
    }
  }
}



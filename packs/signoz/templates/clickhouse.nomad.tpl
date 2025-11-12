# ClickHouse Database Job
job "[[ var "job_name" . ]]_clickhouse"  {
  [[ template "region" . ]]
  datacenters = [[ var "datacenters" . | toStringList ]]
  type = "service"
  node_pool   = [[ var "node_pool" . | quote ]]
  group "clickhouse" {
    count = [[ var "clickhouse_replicas" . ]]

    network {
      mode = "bridge"
      port "http" {
        to = [[ var "clickhouse_http_port" . ]]
      }
      port "tcp" {
        to = [[ var "clickhouse_tcp_port" . ]]
      }
      port "interserver" {
        to = 9009
      }
      port "metrics" {
        to = 9363
      }
    }

    # Persistent data volume
    volume "data" {
      type            = "host"
      source          = [[ var "clickhouse_volume_name" . | quote ]]
      access_mode     = "single-node-single-writer"
      attachment_mode = "file-system"
    }

    # UDF initialization task
    task "clickhouse-udf-init" {
      driver = "docker"

      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      config {
        image   = "docker.io/alpine:3.18.2"
        command = "sh"
        args = [
          "-c",
          <<-EOT
          set -e
          echo "Fetching histogram-binary for $(uname -s | tr '[:upper:]' '[:lower:]')/$(uname -m | sed s/aarch64/arm64/ | sed s/x86_64/amd64/)"
          cd /tmp
          wget -O histogram-quantile.tar.gz "https://github.com/SigNoz/signoz/releases/download/histogram-quantile%2Fv0.0.1/histogram-quantile_$(uname -s | tr '[:upper:]' '[:lower:]')_$(uname -m | sed s/aarch64/arm64/ | sed s/x86_64/amd64/).tar.gz"
          tar -xzf histogram-quantile.tar.gz
          chmod +x histogram-quantile
          mkdir -p /var/lib/clickhouse/user_scripts
          mv histogram-quantile /var/lib/clickhouse/user_scripts/histogramQuantile
          echo "histogram-quantile installed successfully"
          EOT
        ]
      }

      volume_mount {
        volume      = "data"
        destination = "/var/lib/clickhouse"
        read_only   = false
      }
    }

    # Main ClickHouse task
    task "clickhouse" {
      driver = "docker"

      config {
        image   = "docker.io/clickhouse/clickhouse-server:[[ var "clickhouse_version" . ]]"
        command = "/usr/bin/clickhouse-server"
        args    = ["--config-file=/etc/clickhouse-server/config.xml"]
        ports   = ["http", "tcp", "interserver", "metrics"]
        volumes = [
          "local/config.xml:/etc/clickhouse-server/config.xml",
          "local/users.xml:/etc/clickhouse-server/users.xml",
          "local/custom-function.xml:/etc/clickhouse-server/custom-function.xml",
          "local/cluster.xml:/etc/clickhouse-server/config.d/cluster.xml",
        ]
      }

      service {
        name     = "clickhouse-http"
        port     = "http"
        check {
          name     = "http-ping"
          type     = "http"
          path     = "/ping"
          port     = "http"
          interval = "10s"
          timeout  = "3s"
        }
      }

      service {
        name     = "clickhouse-tcp"
        port     = "tcp"
        check {
          name     = "tcp-check"
          type     = "tcp"
          port     = "tcp"
          interval = "10s"
          timeout  = "3s"
        }
      }

      volume_mount {
        volume      = "data"
        destination = "/var/lib/clickhouse"
        read_only   = false
      }

      resources {
        cpu    = [[ var "clickhouse_cpu" . ]]
        memory = [[ var "clickhouse_memory" . ]]
      }

      env {
        CLICKHOUSE_SKIP_USER_SETUP = 1
      }

      # Environment variables for ZooKeeper and ClickHouse
      template {
        env = true
        data = <<EOH
        {{range service "zookeeper"}}
        ZOOKEEPER_PORT={{ .Port }}
        ZOOKEEPER_HOST={{ .Address }}
        {{end}}
        CLICKHOUSE_HOST={{ env "NOMAD_ALLOC_IP_tcp" }}
        CLICKHOUSE_PORT={{ env "NOMAD_ALLOC_PORT_tcp" }}
        EOH
        destination = "local/clickhouse.env"
        change_mode = "restart"
      }
      template {
        destination = "${NOMAD_SECRETS_DIR}/clickhouse.env"
        env         = true
        change_mode = "restart"
        data        = <<EOF
{{- with nomadVar "nomad/jobs" -}}
CLICKHOUSE_PASSWORD = {{ .clickhouse_password }}
{{- end -}}
EOF
      }

      # Configuration templates
      template {
        destination   = "/local/cluster.xml"
        perms         = "0644"
        change_mode   = "signal"
        change_signal = "SIGHUP"
        data          = <<EOH
[[ fileContents "templates/configs/clickhouse/cluster.xml" ]]
        EOH
      }
      template {
        destination   = "/local/users.xml"
        perms         = "0644"
        change_mode   = "signal"
        change_signal = "SIGHUP"
        data          = <<EOH
[[ fileContents "templates/configs/clickhouse/users.xml" ]]
        EOH
      }
      template {
        destination   = "/local/config.xml"
        perms         = "0644"
        change_mode   = "signal"
        change_signal = "SIGHUP"
        data          = <<EOH
[[ fileContents "templates/configs/clickhouse/config.xml" ]]
        EOH
      }
      template {
        destination   = "/local/storage.xml"
        perms         = "0644"
        change_mode   = "signal"
        change_signal = "SIGHUP"
        data          = <<EOH
[[ fileContents "templates/configs/clickhouse/storage.xml" ]]
        EOH
      }
      template {
        destination = "/local/custom-function.xml"
        perms       = "0644"
        data        = <<EOH
[[ fileContents "templates/configs/clickhouse/custom-function.xml" ]]
        EOH
      }
    }
  }

  group "zookeeper" {
    count = [[ var "zookeeper_count" . ]]
    
    network {
      mode = "bridge"
      port "client" { to = 2181 }
      port "follower" { to = 2888 }
      port "election" { to = 3888 }
      port "metrics"  { to = 9141 }
      port "server"   { to = 3181 }
    }

    service {
      name = "zookeeper"
      port = "client"
      check {
        name = "tcp-2181"
        port = "client"
        type = "tcp"
        interval = "10s"
        timeout  = "2s"
      }

    }

    # Persistent data volume
    volume "data" {
      type   = "host"
      access_mode = "single-node-single-writer"
      source = [[ var "zookeeper_volume_name" . | quote ]]
      attachment_mode="file-system"
    }

    task "zookeeper" {
      driver = "docker"
      env = {
        BITNAMI_DEBUG                    = "false"
        ZOO_PORT_NUMBER                  = "2181"
        ZOO_TICK_TIME                    = "2000"
        ZOO_INIT_LIMIT                   = "10"
        ZOO_SYNC_LIMIT                   = "5"
        ZOO_PRE_ALLOC_SIZE               = "65536"
        ZOO_SNAPCOUNT                    = "100000"
        ZOO_MAX_CLIENT_CNXNS             = "60"
        ZOO_4LW_COMMANDS_WHITELIST       = "srvr, mntr, ruok"
        ZOO_AUTOPURGE_INTERVAL           = "1"
        ZOO_AUTOPURGE_RETAIN_COUNT       = "3"
        ZOO_MAX_SESSION_TIMEOUT          = "40000"
        ZOO_SERVERS                      = "0.0.0.0:2888:3888::1"
        ZOO_ENABLE_AUTH                  = "no"
        ZOO_ENABLE_QUORUM_AUTH           = "no"
        ZOO_HEAP_SIZE                    = "1024"
        ZOO_LOG_LEVEL                    = "INFO"
        ALLOW_ANONYMOUS_LOGIN            = "yes"
        ZOO_ENABLE_PROMETHEUS_METRICS    = "yes"
        ZOO_PROMETHEUS_METRICS_PORT_NUMBER = "9141"
        ZOO_ENABLE_ADMIN_SERVER            = "yes"
        ZOO_ADMIN_SERVER_ADDRESS           = "0.0.0.0"
        ZOO_ADMIN_SERVER_PORT_NUMBER       = "3181"
        ZOOKEEPER_DATA_DIR                = "/tmp/bitnami/zookeeper"
      }

      config {
        image = "signoz/zookeeper:3.7.1"
        ports = ["client", "follower", "election", "metrics", "server"]
      }

      volume_mount {
        volume      = "data"
        destination = "/tmp/bitnami/zookeeper/"
        read_only   = false
      }

      resources {
        cpu    = [[ var "zookeeper_cpu" . ]]
        memory = [[ var "zookeeper_memory" . ]]
      }
    }
  }
}

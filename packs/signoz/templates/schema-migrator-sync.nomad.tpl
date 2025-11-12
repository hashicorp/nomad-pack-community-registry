# Schema Migrator Sync Job
job "[[ var "job_name" . ]]_schema_migrator_sync"  {
  [[ template "region" . ]]
  datacenters = [[ var "datacenters" . | toStringList ]]
  type = "batch"
  node_pool   = [[ var "node_pool" . | quote ]]
  group "signoz-schema-migrator-sync" {
    count = 1

    restart {
      attempts = 1
      interval = "10m"
      delay    = "10s"
      mode     = "fail"
    }

    # Wait for ClickHouse HTTP ping
    task "schema-migrator-sync-init" {
      driver = "docker"

      template {
        env = true
        data = <<EOH
{{range service "clickhouse-http"}}
CLICKHOUSE_PORT={{ .Port }}
CLICKHOUSE_HOST={{ .Address }}
{{end}}
EOH
        destination = "local/clickhouse.env"
        change_mode = "restart"
      }

      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      config {
        image = "docker.io/busybox:1.35"
        command = "sh"
        args = [
          "-c",
          <<-EOT
          echo "Waiting for ClickHouse HTTP ping..."
          until wget -q --spider "http://$${CLICKHOUSE_HOST}:$${CLICKHOUSE_PORT}/ping"; do
            echo "waiting for clickhouseDB (HTTP $${CLICKHOUSE_HOST}:$${CLICKHOUSE_PORT}/ping)"; sleep 5;
          done
          echo "ClickHouse HTTP is up"
          EOT
        ]
      }
    }

    # Deep readiness check
    task "schema-migrator-sync-ch-ready" {
      driver = "docker"

      lifecycle {
        hook    = "prestart"
        sidecar = false
      }
      
      [[ template "clickhouse_address" . ]]
      [[ template "clickhouse_password" . ]]
      env {
        CLICKHOUSE_CLUSTER    = [[ var "clickhouse_cluster_name" . | quote ]]
        CLICKHOUSE_VERSION    = [[ var "clickhouse_version" . | quote ]]
        CLICKHOUSE_SHARDS     = [[ var "clickhouse_shards" . | quote ]]
        CLICKHOUSE_REPLICAS   = [[ var "clickhouse_replicas" . | quote ]]
      }

      config {
        image = "docker.io/clickhouse/clickhouse-server:[[ var "clickhouse_version" . ]]"
        command = "sh"
        args = [
          "-c",
          <<-EOT
          echo "Running ClickHouse readiness checks (version/shards/replicas)"
          while true; do
            current_version="$(clickhouse client --host "$${CLICKHOUSE_HOST}" --port "$${CLICKHOUSE_PORT}" --user "$${CLICKHOUSE_USER}" --password "$${CLICKHOUSE_PASSWORD}" -q "SELECT version()" 2>/dev/null)"
            if [ -z "$current_version" ]; then
              echo "waiting for clickhouse to be ready"; sleep 5; continue
            fi
            if ! echo "$current_version" | grep -q "$${CLICKHOUSE_VERSION}"; then
              echo "expected version: $${CLICKHOUSE_VERSION}, current: $current_version"; sleep 5; continue
            fi

            current_shards="$(clickhouse client --host "$${CLICKHOUSE_HOST}" --port "$${CLICKHOUSE_PORT}" --user "$${CLICKHOUSE_USER}" --password "$${CLICKHOUSE_PASSWORD}" -q "SELECT count(DISTINCT shard_num) FROM system.clusters WHERE cluster='$${CLICKHOUSE_CLUSTER}'" 2>/dev/null)"
            if [ -z "$current_shards" ]; then echo "waiting for shards info"; sleep 5; continue; fi
            if [ "$current_shards" -ne "$${CLICKHOUSE_SHARDS}" ]; then
              echo "expected shards: $${CLICKHOUSE_SHARDS}, got: $current_shards"; sleep 5; continue
            fi

            current_replicas="$(clickhouse client --host "$${CLICKHOUSE_HOST}" --port "$${CLICKHOUSE_PORT}" --user "$${CLICKHOUSE_USER}" --password "$${CLICKHOUSE_PASSWORD}" -q "SELECT count(DISTINCT replica_num) FROM system.clusters WHERE cluster='$${CLICKHOUSE_CLUSTER}'" 2>/dev/null)"
            if [ -z "$current_replicas" ]; then echo "waiting for replicas info"; sleep 5; continue; fi
            if [ "$current_replicas" -ne "$${CLICKHOUSE_REPLICAS}" ]; then
              echo "expected replicas: $${CLICKHOUSE_REPLICAS}, got: $current_replicas"; sleep 5; continue
            fi

            break
          done
          echo "ClickHouse ready; proceeding to schema migrator"
          EOT
        ]
      }
    }

    # Main schema migrator task
    task "schema-migrator" {
      driver = "docker"
      
      [[ template "clickhouse_address" . ]]
      [[ template "clickhouse_password" . ]]

      config {
        image = "docker.io/signoz/signoz-schema-migrator:[[ var "schema_migrator_version" . ]]"
        args = [
          "sync",
          "--cluster-name",
          [[ var "clickhouse_cluster_name" . | quote ]],
          "--dsn",
          "tcp://$${CLICKHOUSE_USER}:$${CLICKHOUSE_PASSWORD}@$${CLICKHOUSE_HOST}:$${CLICKHOUSE_PORT}",
          "--up="
        ]
      }
    }
  }
}

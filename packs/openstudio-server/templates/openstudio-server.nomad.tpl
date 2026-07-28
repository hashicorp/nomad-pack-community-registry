job "[[ var "job_name" . ]]" {
  region      = "[[ var "region" . ]]"
  datacenters = [[ var "datacenters" . | toJson ]]
  namespace   = "[[ var "nomad_namespace" . ]]"
  type        = "service"
  meta {
    app_version         = "[[ var "app_version" . ]]"
    worker_min_replicas = "[[ var "worker_min_replicas" . ]]"
    worker_max_replicas = "[[ var "worker_max_replicas" . ]]"
    ingress_domain      = "[[ var "ingress_domain" . ]]"
    vault_integration   = "[[ var "vault_integration_enabled" . ]]"
  }

  # Placeholder groups mapping to openstudio-server components:
  # web, web-background, worker, db, redis, rserve.

  group "web" {
    count = 1

    network {
      port "http" {
        to = 8080
      }
    }

    task "wait-for-dependencies" {
      driver = "docker"

      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      config {
        image   = "busybox:1.36"
        command = "sh"
        args = [
          "-ec",
          "until wget -qO- \"http://consul.service.consul:8500/v1/health/service/openstudio-db?passing=true\" | grep -q '\"ServiceName\":\"openstudio-db\"'; do echo 'waiting for openstudio-db to be healthy in Consul'; sleep 5; done; until wget -qO- \"http://consul.service.consul:8500/v1/health/service/openstudio-redis?passing=true\" | grep -q '\"ServiceName\":\"openstudio-redis\"'; do echo 'waiting for openstudio-redis to be healthy in Consul'; sleep 5; done"
        ]
      }
    }

    task "web" {
      driver = "docker"

      [[ if var "vault_enabled" . ]]
      [[ if var "vault_db_role" . ]]
      vault {
        role = "[[ var "vault_db_role" . ]]"
        [[ if var "vault_policies" . ]]
        policies = [[ var "vault_policies" . | toJson ]]
        [[ end ]]
        [[ if var "vault_namespace" . ]]
        namespace = "[[ var "vault_namespace" . ]]"
        [[ end ]]
        change_mode = "[[ var "vault_change_mode" . ]]"
        [[ if var "vault_change_signal" . ]]
        change_signal = "[[ var "vault_change_signal" . ]]"
        [[ end ]]
        env = [[ var "vault_env" . ]]
      }
      [[ else if var "vault_default_role" . ]]
      vault {
        role = "[[ var "vault_default_role" . ]]"
        [[ if var "vault_policies" . ]]
        policies = [[ var "vault_policies" . | toJson ]]
        [[ end ]]
        [[ if var "vault_namespace" . ]]
        namespace = "[[ var "vault_namespace" . ]]"
        [[ end ]]
        change_mode = "[[ var "vault_change_mode" . ]]"
        [[ if var "vault_change_signal" . ]]
        change_signal = "[[ var "vault_change_signal" . ]]"
        [[ end ]]
        env = [[ var "vault_env" . ]]
      }
      [[ end ]]
      [[ end ]]

      [[ if var "vault_integration_enabled" . ]]
      vault {
        policies      = ["[[ var "vault_policy" . ]]"]
        change_mode   = "restart"
        change_signal = "SIGTERM"
      }

      template {
        destination = "secrets/env"
        env         = true
        change_mode = "restart"
        data        = <<-EOT
{{ with secret "[[ var "vault_kv_mongodb_path" . ]]" }}
MONGO_PASSWORD={{ .Data.data.password }}
{{ end }}
{{ with secret "[[ var "vault_kv_redis_path" . ]]" }}
REDIS_PASSWORD={{ .Data.data.password }}
{{ end }}
{{ with secret "[[ var "vault_kv_app_path" . ]]" }}
APP_SECRET_KEY_BASE={{ .Data.data.secret_key_base }}
{{ end }}
EOT
      }
      [[ end ]]

      config {
        image = "[[ var "web_image" . ]]"
        ports = ["http"]
        logging {
          type = "[[ var "log_driver_type" . ]]"
          config {
            max-size = "[[ var "log_max_size" . ]]"
            max-file = "[[ var "log_max_files" . ]]"
          }
        }
      }

      [[ if var "enable_vault_mongo_secrets" . ]]
      template {
        destination = "secrets/mongodb.env"
        env         = true
        change_mode = "restart"
        data        = <<EOH
{{ with secret "[[ var "vault_mongo_secret_path" . ]]" }}
MONGO_INITDB_ROOT_USERNAME={{ index .Data.data "[[ var "vault_mongo_username_key" . ]]" }}
MONGO_INITDB_ROOT_PASSWORD={{ index .Data.data "[[ var "vault_mongo_password_key" . ]]" }}
{{ end }}
EOH
      }
      [[ end ]]

      service {
        name     = "openstudio-web"
        port     = "http"
        provider = "consul"

        check {
          name     = "openstudio-web-tcp"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }

        check {
          name     = "openstudio-web-liveness"
          type     = "http"
          path     = "/up"
          interval = "10s"
          timeout  = "2s"
        }

        check {
          name     = "openstudio-web-readiness"
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
      }

      resources {
        cpu    = [[ var "db_cpu" . ]]
        memory = [[ var "db_memory" . ]]
      }
    }

    [[ if var "enable_vector_collection" . ]]
    task "vector" {
      driver = "docker"

      [[ if var "vault_enabled" . ]]
      [[ if var "vault_vector_role" . ]]
      vault {
        role = "[[ var "vault_vector_role" . ]]"
        [[ if var "vault_policies" . ]]
        policies = [[ var "vault_policies" . | toJson ]]
        [[ end ]]
        [[ if var "vault_namespace" . ]]
        namespace = "[[ var "vault_namespace" . ]]"
        [[ end ]]
        change_mode = "[[ var "vault_change_mode" . ]]"
        [[ if var "vault_change_signal" . ]]
        change_signal = "[[ var "vault_change_signal" . ]]"
        [[ end ]]
        env = [[ var "vault_env" . ]]
      }
      [[ else if var "vault_default_role" . ]]
      vault {
        role = "[[ var "vault_default_role" . ]]"
        [[ if var "vault_policies" . ]]
        policies = [[ var "vault_policies" . | toJson ]]
        [[ end ]]
        [[ if var "vault_namespace" . ]]
        namespace = "[[ var "vault_namespace" . ]]"
        [[ end ]]
        change_mode = "[[ var "vault_change_mode" . ]]"
        [[ if var "vault_change_signal" . ]]
        change_signal = "[[ var "vault_change_signal" . ]]"
        [[ end ]]
        env = [[ var "vault_env" . ]]
      }
      [[ end ]]
      [[ end ]]

      lifecycle {
        hook    = "prestart"
        sidecar = true
      }

      config {
        image = "[[ var "vector_image" . ]]"
        args  = ["--config", "local/vector.toml"]
      }

      template {
        data        = <<EOH
[sources.alloc_logs]
type = "file"
include = ["/alloc/logs/*.std*"]

[sinks.console]
type = "console"
inputs = ["alloc_logs"]
encoding.codec = "json"
EOH
        destination = "local/vector.toml"
      }

      resources {
        cpu    = 100
        memory = 64
      }
    }
    [[ end ]]
  }

  group "worker" {
    count = [[ var "worker_count" . ]]

    update {
      max_parallel      = [[ var "worker_update_max_parallel" . ]]
      health_check      = "[[ var "worker_update_health_check" . ]]"
      min_healthy_time  = "[[ var "worker_update_min_healthy_time" . ]]"
      healthy_deadline  = "[[ var "worker_update_healthy_deadline" . ]]"
      progress_deadline = "[[ var "worker_update_progress_deadline" . ]]"
      auto_revert       = [[ var "worker_update_auto_revert" . ]]
    }

    task "worker" {
      driver = "docker"

      [[ if var "vault_integration_enabled" . ]]
      vault {
        policies      = ["[[ var "vault_policy" . ]]"]
        change_mode   = "restart"
        change_signal = "SIGTERM"
      }

      template {
        destination = "secrets/env"
        env         = true
        change_mode = "restart"
        data        = <<-EOT
{{ with secret "[[ var "vault_kv_mongodb_path" . ]]" }}
MONGO_PASSWORD={{ .Data.data.password }}
{{ end }}
{{ with secret "[[ var "vault_kv_redis_path" . ]]" }}
REDIS_PASSWORD={{ .Data.data.password }}
{{ end }}
{{ with secret "[[ var "vault_kv_app_path" . ]]" }}
APP_SECRET_KEY_BASE={{ .Data.data.secret_key_base }}
{{ end }}
EOT
      }
      [[ end ]]

      config {
        image = "[[ var "worker_image" . ]]"
        logging {
          type = "[[ var "log_driver_type" . ]]"
          config {
            max-size = "[[ var "log_max_size" . ]]"
            max-file = "[[ var "log_max_files" . ]]"
          }
        }
      }
    }

    [[ if var "enable_vector_collection" . ]]
    task "vector" {
      driver = "docker"

      lifecycle {
        hook    = "prestart"
        sidecar = true
      }

      config {
        image = "[[ var "vector_image" . ]]"
        args  = ["--config", "local/vector.toml"]
      }

      template {
        data        = <<EOH
[sources.alloc_logs]
type = "file"
include = ["/alloc/logs/*.std*"]

[sinks.console]
type = "console"
inputs = ["alloc_logs"]
encoding.codec = "json"
EOH
        destination = "local/vector.toml"
      }

      resources {
        cpu    = 100
        memory = 64
      }
    }
    [[ end ]]
  }

  group "db" {
    count = 1
    [[ if ne (var "mongodb_storage_type" .) "ephemeral" ]]
    volume "mongodb_data" {
      type      = "[[ var "mongodb_storage_type" . ]]"
      source    = "[[ var "mongodb_volume_source" . ]]"
      read_only = false
    }
    [[ end ]]
    [[ template "constraints" (var "db_constraints" .) ]]
    [[ template "affinities" (var "db_affinities" .) ]]
    [[ template "spreads" (var "db_spreads" .) ]]

    network {
      port "db" {
        to = 27017
      }
    }

    task "mongodb" {
      driver = "docker"

      config {
        image           = "[[ var "db_image" . ]]"
        ports           = ["db"]
        user            = "[[ var "docker_user" . ]]"
        readonly_rootfs = [[ var "docker_readonly_rootfs" . ]]
        cap_drop        = [[ var "docker_cap_drop" . | toJson ]]
        logging {
          type = "[[ var "log_driver_type" . ]]"
          config {
            max-size = "[[ var "log_max_size" . ]]"
            max-file = "[[ var "log_max_files" . ]]"
          }
        }
      }

      [[ if ne (var "mongodb_storage_type" .) "ephemeral" ]]
      volume_mount {
        volume      = "mongodb_data"
        destination = "/data/db"
        read_only   = false
      }
      [[ end ]]

      env {
        APP_VERSION               = "[[ var "app_version" . ]]"
        MONGODB_STORAGE_TYPE      = "[[ var "mongodb_storage_type" . ]]"
        MONGODB_VOLUME_SOURCE     = "[[ var "mongodb_volume_source" . ]]"
        WORKER_MIN_REPLICAS       = "[[ var "worker_min_replicas" . ]]"
        WORKER_MAX_REPLICAS       = "[[ var "worker_max_replicas" . ]]"
        VAULT_INTEGRATION_ENABLED = "[[ var "vault_integration_enabled" . ]]"
        INGRESS_DOMAIN            = "[[ var "ingress_domain" . ]]"
      }

      [[ if var "vault_integration_enabled" . ]]
      vault {
        policies      = ["[[ var "vault_policy" . ]]"]
        change_mode   = "restart"
        change_signal = "SIGTERM"
      }

      template {
        destination = "secrets/env"
        env         = true
        change_mode = "restart"
        data        = <<-EOT
{{ with secret "[[ var "vault_kv_mongodb_path" . ]]" }}
MONGO_PASSWORD={{ .Data.data.password }}
{{ end }}
EOT
      }
      [[ end ]]

      service {
        name     = "openstudio-db"
        port     = "db"
        provider = "consul"
        tags = [
          "ingress.domain=[[ var "ingress_domain" . ]]"
        ]

        [[ if var "enable_consul_connect" . ]]
        connect {
          sidecar_service {
            proxy {
              local_service_address = "127.0.0.1"
              local_service_port    = 27017
            }
          }
        }
        [[ end ]]

        check {
          name     = "openstudio-db-tcp"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }

    task "cleanup-poststop" {
      driver = "docker"

      lifecycle {
        hook = "poststop"
      }

      config {
        image   = "[[ var "poststop_cleanup_image" . ]]"
        command = "sh"
        args = [
          "-ec",
          <<EOT
set -eu
[[ range var "poststop_cleanup_paths" . -]]
rm -rf "[[ . ]]"
[[ end -]]
EOT
        ]
      }
    }

    [[ if var "enable_vector_collection" . ]]
    task "vector" {
      driver = "docker"

      lifecycle {
        hook    = "prestart"
        sidecar = true
      }

      config {
        image           = "[[ var "vector_image" . ]]"
        args            = ["--config", "local/vector.toml"]
        user            = "[[ var "docker_user" . ]]"
        readonly_rootfs = [[ var "docker_readonly_rootfs" . ]]
        cap_drop        = [[ var "docker_cap_drop" . | toJson ]]
      }

      template {
        data        = <<EOH
[sources.alloc_logs]
type = "file"
include = ["/alloc/logs/*.std*"]

[sinks.console]
type = "console"
inputs = ["alloc_logs"]
encoding.codec = "json"
EOH
        destination = "local/vector.toml"
      }

      resources {
        cpu    = 100
        memory = 64
      }
    }
    [[ end ]]
  }

  group "redis" {
    count = 1
    [[ template "constraints" (var "redis_constraints" .) ]]
    [[ template "affinities" (var "redis_affinities" .) ]]
    [[ template "spreads" (var "redis_spreads" .) ]]

    network {
      port "redis" {
        to = 6379
      }
    }

    task "redis" {
      driver = "docker"

      [[ if var "vault_enabled" . ]]
      [[ if var "vault_redis_role" . ]]
      vault {
        role = "[[ var "vault_redis_role" . ]]"
        [[ if var "vault_policies" . ]]
        policies = [[ var "vault_policies" . | toJson ]]
        [[ end ]]
        [[ if var "vault_namespace" . ]]
        namespace = "[[ var "vault_namespace" . ]]"
        [[ end ]]
        change_mode = "[[ var "vault_change_mode" . ]]"
        [[ if var "vault_change_signal" . ]]
        change_signal = "[[ var "vault_change_signal" . ]]"
        [[ end ]]
        env = [[ var "vault_env" . ]]
      }
      [[ else if var "vault_default_role" . ]]
      vault {
        role = "[[ var "vault_default_role" . ]]"
        [[ if var "vault_policies" . ]]
        policies = [[ var "vault_policies" . | toJson ]]
        [[ end ]]
        [[ if var "vault_namespace" . ]]
        namespace = "[[ var "vault_namespace" . ]]"
        [[ end ]]
        change_mode = "[[ var "vault_change_mode" . ]]"
        [[ if var "vault_change_signal" . ]]
        change_signal = "[[ var "vault_change_signal" . ]]"
        [[ end ]]
        env = [[ var "vault_env" . ]]
      }
      [[ end ]]
      [[ end ]]

      config {
        image           = "[[ var "redis_image" . ]]"
        ports           = ["redis"]
        user            = "[[ var "docker_user" . ]]"
        readonly_rootfs = [[ var "docker_readonly_rootfs" . ]]
        cap_drop        = [[ var "docker_cap_drop" . | toJson ]]
        logging {
          type = "[[ var "log_driver_type" . ]]"
          config {
            max-size = "[[ var "log_max_size" . ]]"
            max-file = "[[ var "log_max_files" . ]]"
          }
        }
      }

      service {
        name     = "openstudio-redis"
        port     = "redis"
        provider = "consul"
        tags = [
          "ingress.domain=[[ var "ingress_domain" . ]]"
        ]

        [[ if var "enable_consul_connect" . ]]
        connect {
          sidecar_service {
            proxy {
              local_service_address = "127.0.0.1"
              local_service_port    = 6379
            }
          }
        }
        [[ end ]]

        check {
          name     = "openstudio-redis-tcp"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }

      resources {
        cpu    = [[ var "redis_cpu" . ]]
        memory = [[ var "redis_memory" . ]]
      }

      [[ if var "vault_integration_enabled" . ]]
      vault {
        policies      = ["[[ var "vault_policy" . ]]"]
        change_mode   = "restart"
        change_signal = "SIGTERM"
      }

      template {
        destination = "secrets/env"
        env         = true
        change_mode = "restart"
        data        = <<-EOT
{{ with secret "[[ var "vault_kv_redis_path" . ]]" }}
REDIS_PASSWORD={{ .Data.data.password }}
{{ end }}
EOT
      }
      [[ end ]]
    }

    task "cleanup-poststop" {
      driver = "docker"

      lifecycle {
        hook = "poststop"
      }

      config {
        image   = "[[ var "poststop_cleanup_image" . ]]"
        command = "sh"
        args = [
          "-ec",
          <<EOT
set -eu
[[ range var "poststop_cleanup_paths" . -]]
rm -rf "[[ . ]]"
[[ end -]]
EOT
        ]
      }
    }

    [[ if var "enable_vector_collection" . ]]
    task "vector" {
      driver = "docker"

      [[ if var "vault_enabled" . ]]
      [[ if var "vault_vector_role" . ]]
      vault {
        role = "[[ var "vault_vector_role" . ]]"
        [[ if var "vault_policies" . ]]
        policies = [[ var "vault_policies" . | toJson ]]
        [[ end ]]
        [[ if var "vault_namespace" . ]]
        namespace = "[[ var "vault_namespace" . ]]"
        [[ end ]]
        change_mode = "[[ var "vault_change_mode" . ]]"
        [[ if var "vault_change_signal" . ]]
        change_signal = "[[ var "vault_change_signal" . ]]"
        [[ end ]]
        env = [[ var "vault_env" . ]]
      }
      [[ else if var "vault_default_role" . ]]
      vault {
        role = "[[ var "vault_default_role" . ]]"
        [[ if var "vault_policies" . ]]
        policies = [[ var "vault_policies" . | toJson ]]
        [[ end ]]
        [[ if var "vault_namespace" . ]]
        namespace = "[[ var "vault_namespace" . ]]"
        [[ end ]]
        change_mode = "[[ var "vault_change_mode" . ]]"
        [[ if var "vault_change_signal" . ]]
        change_signal = "[[ var "vault_change_signal" . ]]"
        [[ end ]]
        env = [[ var "vault_env" . ]]
      }
      [[ end ]]
      [[ end ]]

      lifecycle {
        hook    = "prestart"
        sidecar = true
      }

      config {
        image           = "[[ var "vector_image" . ]]"
        args            = ["--config", "local/vector.toml"]
        user            = "[[ var "docker_user" . ]]"
        readonly_rootfs = [[ var "docker_readonly_rootfs" . ]]
        cap_drop        = [[ var "docker_cap_drop" . | toJson ]]
      }

      template {
        data        = <<EOH
[sources.alloc_logs]
type = "file"
include = ["/alloc/logs/*.std*"]

[sinks.console]
type = "console"
inputs = ["alloc_logs"]
encoding.codec = "json"
EOH
        destination = "local/vector.toml"
      }

      resources {
        cpu    = 100
        memory = 64
      }
    }
    [[ end ]]
  }

  group "web-background" {
    count = [[ var "web_background_count" . ]]

    task "web-background" {
      driver = "docker"

      [[ if var "vault_integration_enabled" . ]]
      vault {
        policies      = ["[[ var "vault_policy" . ]]"]
        change_mode   = "restart"
        change_signal = "SIGTERM"
      }

      template {
        destination = "secrets/env"
        env         = true
        change_mode = "restart"
        data        = <<-EOT
{{ with secret "[[ var "vault_kv_mongodb_path" . ]]" }}
MONGO_PASSWORD={{ .Data.data.password }}
{{ end }}
{{ with secret "[[ var "vault_kv_redis_path" . ]]" }}
REDIS_PASSWORD={{ .Data.data.password }}
{{ end }}
{{ with secret "[[ var "vault_kv_app_path" . ]]" }}
APP_SECRET_KEY_BASE={{ .Data.data.secret_key_base }}
{{ end }}
EOT
      }
      [[ end ]]

      config {
        image   = "[[ var "web_background_image" . ]]"
        command = "/usr/local/bin/start-web-background"
        logging {
          type = "[[ var "log_driver_type" . ]]"
          config {
            max-size = "[[ var "log_max_size" . ]]"
            max-file = "[[ var "log_max_files" . ]]"
          }
        }
      }

      env {
        QUEUES     = "background,analyses"
        REDIS_URL  = "redis://openstudio-redis.service.consul:6379"
        MONGO_USER = "openstudio"
        [[ if not (var "vault_integration_enabled" .) ]]
        MONGO_PASSWORD      = "[[ var "mongo_password" . ]]"
        REDIS_PASSWORD      = "[[ var "redis_password" . ]]"
        APP_SECRET_KEY_BASE = "[[ var "app_secret_key_base" . ]]"
        [[ end ]]
      }
    }

    [[ if var "enable_vector_collection" . ]]
    task "vector" {
      driver = "docker"

      lifecycle {
        hook    = "prestart"
        sidecar = true
      }

      config {
        image = "[[ var "vector_image" . ]]"
        args  = ["--config", "local/vector.toml"]
      }

      template {
        data        = <<EOH
[sources.alloc_logs]
type = "file"
include = ["/alloc/logs/*.std*"]

[sinks.console]
type = "console"
inputs = ["alloc_logs"]
encoding.codec = "json"
EOH
        destination = "local/vector.toml"
      }

      resources {
        cpu    = 100
        memory = 64
      }
    }
    [[ end ]]
  }
}

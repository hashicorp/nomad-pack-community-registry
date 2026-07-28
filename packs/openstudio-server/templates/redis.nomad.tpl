job "[[ var "job_name" . ]]-redis" {
  region      = "[[ var "region" . ]]"
  datacenters = [[ var "datacenters" . | toJson ]]
  namespace   = "[[ var "nomad_namespace" . ]]"
  type        = "service"
  meta {
    app_version       = "[[ var "app_version" . ]]"
    ingress_domain    = "[[ var "ingress_domain" . ]]"
    vault_integration = "[[ var "vault_integration_enabled" . ]]"
  }

  group "redis" {
    count = 1
    [[ template "constraints" (var "redis_constraints" .) ]]
    [[ template "affinities" (var "redis_affinities" .) ]]
    [[ template "spreads" (var "redis_spreads" .) ]]

    [[ if ne (var "redis_storage_type" .) "ephemeral" ]]
    [[ if eq (var "redis_storage_type" .) "csi" ]]
    volume "redis-data" {
      type            = "csi"
      source          = "[[ var "redis_volume_source" . ]]"
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }
    [[ else ]]
    volume "redis-data" {
      type      = "host"
      source    = "[[ var "redis_volume_source" . ]]"
      read_only = false
    }
    [[ end ]]
    [[ end ]]

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

      [[ if ne (var "redis_storage_type" .) "ephemeral" ]]
      volume_mount {
        volume      = "redis-data"
        destination = "/data"
        read_only   = false
      }
      [[ end ]]

      config {
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
          interval = "[[ var "redis_health_check_interval" . ]]"
          timeout  = "[[ var "redis_health_check_timeout" . ]]"
        }
      }

      resources {
        cpu    = [[ var "redis_cpu" . ]]
        memory = [[ var "redis_memory" . ]]
      }

      env {
        APP_VERSION               = "[[ var "app_version" . ]]"
        VAULT_INTEGRATION_ENABLED = "[[ var "vault_integration_enabled" . ]]"
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
  }
}

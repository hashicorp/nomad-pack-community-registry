job "[[ var "job_name" . ]]-db" {
  region      = "[[ var "region" . ]]"
  datacenters = [[ var "datacenters" . | toJson ]]
  namespace   = "[[ var "nomad_namespace" . ]]"
  type        = "service"
  meta {
    app_version       = "[[ var "app_version" . ]]"
    ingress_domain    = "[[ var "ingress_domain" . ]]"
    vault_integration = "[[ var "vault_integration_enabled" . ]]"
  }

  group "db" {
    count = 1
    [[ template "constraints" (var "db_constraints" .) ]]
    [[ template "affinities" (var "db_affinities" .) ]]
    [[ template "spreads" (var "db_spreads" .) ]]

    [[ if ne (var "mongodb_storage_type" .) "ephemeral" ]]
    [[ if eq (var "mongodb_storage_type" .) "csi" ]]
    volume "mongodb-data" {
      type            = "csi"
      source          = "[[ var "mongodb_volume_source" . ]]"
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }
    [[ else ]]
    volume "mongodb-data" {
      type      = "host"
      source    = "[[ var "mongodb_volume_source" . ]]"
      read_only = false
    }
    [[ end ]]
    [[ end ]]

    network {
      port "db" {
        to = 27017
      }
    }

    task "mongodb" {
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

      [[ if ne (var "mongodb_storage_type" .) "ephemeral" ]]
      volume_mount {
        volume      = "mongodb-data"
        destination = "/data/db"
        read_only   = false
      }
      [[ end ]]

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

      service {
        name     = "openstudio-db"
        port     = "db"
        provider = "consul"

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
          interval = "[[ var "db_health_check_interval" . ]]"
          timeout  = "[[ var "db_health_check_timeout" . ]]"
        }
      }

      resources {
        cpu    = [[ var "db_cpu" . ]]
        memory = [[ var "db_memory" . ]]
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
{{ with secret "[[ var "vault_kv_mongodb_path" . ]]" }}
MONGO_PASSWORD={{ .Data.data.password }}
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

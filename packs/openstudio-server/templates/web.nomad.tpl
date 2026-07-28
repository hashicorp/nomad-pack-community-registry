job "[[ var "job_name" . ]]-web" {
  region      = "[[ var "region" . ]]"
  datacenters = [[ var "datacenters" . | toJson ]]
  namespace   = "[[ var "nomad_namespace" . ]]"
  type        = "service"
  priority    = [[ var "web_priority" . ]]

  update {
    max_parallel      = [[ var "web_update_max_parallel" . ]]
    health_check      = "[[ var "web_update_health_check" . ]]"
    min_healthy_time  = "[[ var "web_update_min_healthy_time" . ]]"
    healthy_deadline  = "[[ var "web_update_healthy_deadline" . ]]"
    progress_deadline = "[[ var "web_update_progress_deadline" . ]]"
    auto_revert       = [[ var "web_update_auto_revert" . ]]
  }

  group "web" {
    count = [[ var "web_count" . ]]

    [[ if var "nfs_shared_volume_enabled" . ]]
    volume "nfs-shared" {
      type            = "csi"
      source          = "[[ var "nfs_volume_source" . ]]"
      access_mode     = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }
    [[ end ]]

    network {
      port "http" {
        static = [[ var "web_port" . ]]
        to     = 8080
      }
    }

    # Prestart: wait for MongoDB and Redis to be registered and healthy in Consul
    task "wait-for-deps" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      driver = "docker"

      config {
        image   = "consul:latest"
        command = "/bin/sh"
        args = [
          "-c",
          "until consul catalog services | grep -q openstudio-db && consul catalog services | grep -q openstudio-redis; do sleep 2; done",
        ]
      }

      resources {
        cpu    = 50
        memory = 32
      }
    }

    task "web" {
      driver = "docker"

      [[ if var "nfs_shared_volume_enabled" . ]]
      volume_mount {
        volume      = "nfs-shared"
        destination = "[[ var "nfs_volume_mount_path" . ]]"
        read_only   = false
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

      service {
        name     = "openstudio-web"
        port     = "http"
        provider = "consul"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.[[ var "job_name" . ]].rule=Host(`[[ var "ingress_domain" . ]]`)",
          "traefik.http.routers.[[ var "job_name" . ]].entrypoints=web",
          "traefik.http.services.[[ var "job_name" . ]].loadbalancer.server.port=$${NOMAD_PORT_http}",
          [[ if var "ingress_tls_enabled" . ]]
          "traefik.http.routers.[[ var "job_name" . ]]-tls.rule=Host(`[[ var "ingress_domain" . ]]`)",
          "traefik.http.routers.[[ var "job_name" . ]]-tls.entrypoints=websecure",
          "traefik.http.routers.[[ var "job_name" . ]]-tls.tls=true",
          [[ end ]]
        ]

        check {
          name     = "openstudio-web-http"
          type     = "http"
          path     = "/status"
          interval = "[[ var "web_health_check_interval" . ]]"
          timeout  = "[[ var "web_health_check_timeout" . ]]"
        }
      }

      resources {
        cpu        = [[ var "web_cpu" . ]]
        memory     = [[ var "web_memory" . ]]
        memory_max = [[ var "web_memory_max" . ]]
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

  group "web-background" {
    count = [[ var "web_background_count" . ]]

    [[ if var "nfs_shared_volume_enabled" . ]]
    volume "nfs-shared" {
      type            = "csi"
      source          = "[[ var "nfs_volume_source" . ]]"
      access_mode     = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }
    [[ end ]]

    # Prestart: wait for MongoDB, Redis, and the web service to be healthy in Consul
    task "wait-for-deps" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      driver = "docker"

      config {
        image   = "consul:latest"
        command = "/bin/sh"
        args = [
          "-c",
          "until consul catalog services | grep -q openstudio-db && consul catalog services | grep -q openstudio-redis && consul catalog services | grep -q openstudio-web; do sleep 2; done",
        ]
      }

      resources {
        cpu    = 50
        memory = 32
      }
    }

    task "web-background" {
      driver = "docker"

      [[ if var "nfs_shared_volume_enabled" . ]]
      volume_mount {
        volume      = "nfs-shared"
        destination = "[[ var "nfs_volume_mount_path" . ]]"
        read_only   = false
      }
      [[ end ]]

      config {
        image = "[[ var "web_background_image" . ]]"
        logging {
          type = "[[ var "log_driver_type" . ]]"
          config {
            max-size = "[[ var "log_max_size" . ]]"
            max-file = "[[ var "log_max_files" . ]]"
          }
        }
      }

      service {
        name     = "openstudio-web-background"
        provider = "consul"

        tags = []

        check {
          name     = "openstudio-web-background-alive"
          type     = "script"
          command  = "/bin/sh"
          args     = ["-c", "exit 0"]
          interval = "[[ var "web_health_check_interval" . ]]"
          timeout  = "[[ var "web_health_check_timeout" . ]]"
          task     = "web-background"
        }
      }

      resources {
        cpu    = [[ var "web_background_cpu" . ]]
        memory = [[ var "web_background_memory" . ]]
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

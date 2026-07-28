job "[[ var "job_name" . ]]-worker" {
  region      = "[[ var "region" . ]]"
  datacenters = [[ var "datacenters" . | toJson ]]
  namespace   = "[[ var "nomad_namespace" . ]]"
  type        = "service"
  priority    = [[ var "worker_priority" . ]]

  update {
    max_parallel      = [[ var "worker_update_max_parallel" . ]]
    health_check      = "[[ var "worker_update_health_check" . ]]"
    min_healthy_time  = "[[ var "worker_update_min_healthy_time" . ]]"
    healthy_deadline  = "[[ var "worker_update_healthy_deadline" . ]]"
    progress_deadline = "[[ var "worker_update_progress_deadline" . ]]"
    auto_revert       = [[ var "worker_update_auto_revert" . ]]
  }

  group "worker" {
    count = [[ var "worker_count" . ]]

    [[ if var "worker_autoscaling_enabled" . ]]
    scaling {
      enabled = true
      min     = [[ var "worker_min_replicas" . ]]
      max     = [[ var "worker_max_replicas" . ]]

      policy {
        cooldown            = "[[ var "autoscaler_cooldown" . ]]"
        evaluation_interval = "30s"

        check "queue-requeued-depth" {
          source = "prometheus"
          query  = [[ var "worker_queue_requeued_query" . | toJson ]]

          config {
            prometheus_address = "[[ var "autoscaler_prometheus_address" . ]]"
          }

          strategy "target-value" {
            target = [[ var "worker_queue_requeued_target" . ]]
          }
        }

        check "queue-simulations-depth" {
          source = "prometheus"
          query  = [[ var "worker_queue_simulations_query" . | toJson ]]

          config {
            prometheus_address = "[[ var "autoscaler_prometheus_address" . ]]"
          }

          strategy "target-value" {
            target = [[ var "worker_queue_simulations_target" . ]]
          }
        }
      }
    }
    [[ end ]]
    [[ if var "nfs_shared_volume_enabled" . ]]
    volume "nfs-shared" {
      type            = "csi"
      source          = "[[ var "nfs_volume_source" . ]]"
      access_mode     = "multi-node-multi-writer"
      attachment_mode = "file-system"
    }
    [[ end ]]
    [[ template "openstudio_server.arch_constraint" . ]]

    task "worker" {
      driver = "docker"

      [[ if var "nfs_shared_volume_enabled" . ]]
      volume_mount {
        volume      = "nfs-shared"
        destination = "[[ var "nfs_volume_mount_path" . ]]"
        read_only   = false
      }
      [[ end ]]

      config {
        image   = "[[ var "worker_image" . ]]"
        command = "/usr/local/bin/start-workers"
        logging {
          type = "[[ var "log_driver_type" . ]]"
          config {
            max-size = "[[ var "log_max_size" . ]]"
            max-file = "[[ var "log_max_files" . ]]"
          }
        }
      }

      env {
        QUEUES = "[[ var "worker_queues" . ]]"
        COUNT  = "[[ var "worker_process_count" . ]]"
      }

      resources {
        cpu    = [[ var "worker_cpu" . ]]
        memory = [[ var "worker_memory" . ]]
      }

      service {
        name     = "openstudio-worker"
        provider = "consul"

        check {
          name     = "worker-alive"
          type     = "script"
          command  = "/bin/sh"
          args     = ["-c", "pgrep -f resque > /dev/null"]
          interval = "30s"
          timeout  = "5s"
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
}

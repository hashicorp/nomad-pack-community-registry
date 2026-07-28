[[ if var "enable_image_prepull" . ]]
job "[[ var "job_name" . ]]-system-hooks" {
  region      = "[[ var "region" . ]]"
  datacenters = [[ var "datacenters" . | toJson ]]
  namespace   = "[[ var "nomad_namespace" . ]]"
  type        = "system"

  # Only schedule on nodes that have the Docker driver enabled.
  constraint {
    attribute = "${driver.docker}"
    value     = "1"
  }

  group "prepull-images" {
    restart {
      attempts = 3
      mode     = "fail"
    }

    task "pull-web-image" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      driver = "docker"

      kill_timeout = "[[ var "prepull_kill_timeout" . ]]"

      config {
        image   = "[[ var "web_image" . ]]"
        command = "sh"
        args    = ["-c", "echo pulled web image"]
        logging {
          type = "[[ var "log_driver_type" . ]]"
          config {
            max-size = "[[ var "log_max_size" . ]]"
            max-file = "[[ var "log_max_files" . ]]"
          }
        }
      }

      resources {
        cpu    = 100
        memory = 64
      }
    }

    task "pull-worker-image" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      driver = "docker"

      kill_timeout = "[[ var "prepull_kill_timeout" . ]]"

      config {
        image   = "[[ var "worker_image" . ]]"
        command = "sh"
        args    = ["-c", "echo pulled worker image"]
        logging {
          type = "[[ var "log_driver_type" . ]]"
          config {
            max-size = "[[ var "log_max_size" . ]]"
            max-file = "[[ var "log_max_files" . ]]"
          }
        }
      }

      resources {
        cpu    = 100
        memory = 64
      }
    }

    task "pull-db-image" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      driver = "docker"

      kill_timeout = "[[ var "prepull_kill_timeout" . ]]"

      config {
        image   = "[[ var "db_image" . ]]"
        command = "sh"
        args    = ["-c", "echo pulled db image"]
        logging {
          type = "[[ var "log_driver_type" . ]]"
          config {
            max-size = "[[ var "log_max_size" . ]]"
            max-file = "[[ var "log_max_files" . ]]"
          }
        }
      }

      resources {
        cpu    = 100
        memory = 64
      }
    }

    task "pull-redis-image" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      driver = "docker"

      kill_timeout = "[[ var "prepull_kill_timeout" . ]]"

      config {
        image   = "[[ var "redis_image" . ]]"
        command = "sh"
        args    = ["-c", "echo pulled redis image"]
        logging {
          type = "[[ var "log_driver_type" . ]]"
          config {
            max-size = "[[ var "log_max_size" . ]]"
            max-file = "[[ var "log_max_files" . ]]"
          }
        }
      }

      resources {
        cpu    = 100
        memory = 64
      }
    }

    task "pull-rserve-image" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      driver = "docker"

      kill_timeout = "[[ var "prepull_kill_timeout" . ]]"

      config {
        image   = "[[ var "rserve_image" . ]]"
        command = "sh"
        args    = ["-c", "echo pulled rserve image"]
        logging {
          type = "[[ var "log_driver_type" . ]]"
          config {
            max-size = "[[ var "log_max_size" . ]]"
            max-file = "[[ var "log_max_files" . ]]"
          }
        }
      }

      resources {
        cpu    = 100
        memory = 64
      }
    }

    # Long-running sentinel task that keeps the allocation alive after all
    # prestart tasks complete, so the node retains the pre-pulled image layers.
    task "image-cache-ready" {
      driver = "docker"

      kill_timeout = "[[ var "prepull_kill_timeout" . ]]"

      config {
        image   = "alpine:3.20"
        command = "sh"
        args    = ["-c", "sleep infinity"]
        logging {
          type = "[[ var "log_driver_type" . ]]"
          config {
            max-size = "[[ var "log_max_size" . ]]"
            max-file = "[[ var "log_max_files" . ]]"
          }
        }
      }

      resources {
        cpu    = 20
        memory = 32
      }
    }
  }
}
[[ end ]]

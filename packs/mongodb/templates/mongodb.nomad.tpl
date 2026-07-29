# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

job "[[ var "job_name" . ]]" {
  type        = "service"
  region      = "[[ var "region" . ]]"
  namespace   = "[[ var "namespace" . ]]"
  datacenters = [[ var "datacenters" . | toStringList ]]

  update {
    max_parallel      = [[ var "update_max_parallel" . ]]
    min_healthy_time  = "[[ var "update_min_healthy_time" . ]]"
    healthy_deadline  = "[[ var "update_healthy_deadline" . ]]"
    progress_deadline = "10m"
    auto_revert       = true
    canary            = 0
  }

  group "mongodb" {
    count = 1

    restart {
      attempts = [[ var "restart_attempts" . ]]
      interval = "[[ var "restart_interval" . ]]"
      delay    = "15s"
      mode     = "fail"
    }

    network {
      port "db" {
        static = [[ var "mongo_port" . ]]
        to     = [[ var "mongo_port" . ]]
      }
    }

    [[ if var "use_host_volume" . ]]
    volume "mongodb-data" {
      type      = "host"
      read_only = false
      source    = "[[ var "host_volume_name" . ]]"
    }
    [[ end ]]

    task "mongodb" {
      driver = "docker"

      config {
        image = "[[ var "mongo_image" . ]]:[[ var "mongo_image_tag" . ]]"
        ports = ["db"]

        command = "mongod"
        args    = [
          "--bind_ip",   "[[ var "bind_ip" . ]]",
          "--port",      "[[ var "mongo_port" . ]]",
          "--dbpath",    "[[ var "data_dir" . ]]",
          [[ if var "auth_enabled" . ]]"--auth",[[ end ]]
          "--wiredTigerCacheSizeGB", "0.5",
        ]
      }

      [[ if var "use_host_volume" . ]]
      volume_mount {
        volume      = "mongodb-data"
        destination = "[[ var "data_dir" . ]]"
        read_only   = false
      }
      [[ end ]]

      [[ if var "auth_enabled" . ]]
      env {
        MONGO_INITDB_ROOT_USERNAME = "[[ var "root_username" . ]]"
        MONGO_INITDB_ROOT_PASSWORD = "[[ var "root_password" . ]]"
      }
      [[ end ]]

      # ── Nomad native service ──────────────────────────────────────────────
      [[ if var "register_nomad_service" . ]]
      service {
        name      = "[[ var "nomad_service_name" . ]]"
        port      = "db"
        tags      = [[ var "nomad_service_tags" . | toStringList ]]
        provider  = "nomad"   # <-- key change: no Consul dependency

        check {
          name     = "mongodb-health"
          type     = "tcp"
          port     = "db"
          interval = "[[ var "health_check_interval" . ]]"
          timeout  = "[[ var "health_check_timeout" . ]]"
        }
      }
      [[ end ]]

      resources {
        cpu        = [[ var "cpu" . ]]
        memory     = [[ var "memory" . ]]
        [[ if gt (var "memory_max" .) 0 ]]
        memory_max = [[ var "memory_max" . ]]
        [[ end ]]
      }

      logs {
        max_files     = 5
        max_file_size = 20
      }
    }
  }
}

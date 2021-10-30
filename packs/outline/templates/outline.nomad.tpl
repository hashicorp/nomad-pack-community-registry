job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [ [[ range $idx, $dc := .outline.datacenters ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]
  type = "service"

  group "outline-postgresql" {
    count = 1

    network {
      mode = "bridge"
    }

    update {
      min_healthy_time  = [[ .outline.postgresql_group_update.min_healthy_time | quote ]]
      healthy_deadline  = [[ .outline.postgresql_group_update.healthy_deadline | quote ]]
      progress_deadline = [[ .outline.postgresql_group_update.progress_deadline | quote ]]
      auto_revert       = [[ .outline.postgresql_group_update.auto_revert ]]
    }

    service {
      name = [[ .outline.postgresql_group_consul_service_name | quote ]]
      port = [[ .outline.postgresql_group_consul_service_port | quote ]]
      tags = [ [[ range $idx, $tag := .outline.postgresql_group_consul_tags ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]

      connect {
        sidecar_service {}
      }
    }

    restart {
      attempts = [[ .outline.postgresql_group_restart_attempts ]]
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "outline-postgresql" {
      driver = "docker"
      user = 1001

      config {
        image = [[.outline.postgresql_task_image | quote]]
        volumes = [
          "[[.outline.postgresql_task_volume_path]]:/bitnami/postgresql",
        ]
      }

      [[- $postgresql_task_env_vars_length := len .outline.postgresql_task_env_vars ]]
      [[- if not (eq $postgresql_task_env_vars_length 0) ]]
      env {
        [[- range $var := .outline.postgresql_task_env_vars ]]
        [[ $var.key ]] = [[ $var.value | quote ]]
        [[- end ]]
      }
      [[- end ]]

      resources {
        cpu    = [[ .outline.postgresql_task_resources.cpu ]]
        memory = [[ .outline.postgresql_task_resources.memory ]]
      }
    }

    task "create-postgresql-data-folder" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "raw_exec"
      
      config {
        command = "sh"
        args = ["-c", "mkdir -p [[.outline.postgresql_task_volume_path]] && chown 1001:1001 [[.outline.postgresql_task_volume_path]]"]
      }

      resources {
        cpu    = [[ .outline.postgresql_data_folder_task_resources.cpu ]]
        memory = [[ .outline.postgresql_data_folder_task_resources.memory ]]
      }
    }
  }

  group "outline-minio" {
    count = 1

    network {
      mode = "bridge"
      [[- range $port := .outline.minio_group_network ]]
      port [[ $port.name | quote ]] {
        to = [[ $port.port ]]
        static = [[ $port.port ]]
      }
      [[- end ]]
    }

    update {
      min_healthy_time  = [[ .outline.minio_group_update.min_healthy_time | quote ]]
      healthy_deadline  = [[ .outline.minio_group_update.healthy_deadline | quote ]]
      progress_deadline = [[ .outline.minio_group_update.progress_deadline | quote ]]
      auto_revert       = [[ .outline.minio_group_update.auto_revert ]]
    }

    service {
      name = [[ .outline.minio_group_consul_service_name | quote ]]
      port = [[ .outline.minio_group_consul_service_port | quote ]]
      tags = [ [[ range $idx, $tag := .outline.minio_group_consul_tags ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]

      connect {
        sidecar_service {}
      }

      check {
        name = "outline-minio"
        type = "http"
        path = "/minio/health/live"
        interval = "10s"
        timeout = "2s"
      }
    }

    restart {
      attempts = [[ .outline.minio_group_restart_attempts ]]
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "outline-minio" {
      driver = "docker"
      user = 1001

      config {
        image = [[.outline.minio_task_image | quote]]
        volumes = [
          "[[.outline.minio_task_volume_path]]:/data",
        ]
      }

      [[- $minio_task_env_vars_length := len .outline.minio_task_env_vars ]]
      [[- if not (eq $minio_task_env_vars_length 0) ]]
      env {
        [[- range $var := .outline.minio_task_env_vars ]]
        [[ $var.key ]] = [[ $var.value | quote ]]
        [[- end ]]
      }
      [[- end ]]

      resources {
        cpu    = [[ .outline.minio_task_resources.cpu ]]
        memory = [[ .outline.minio_task_resources.memory ]]
      }

      template {
        data = <<EOF
          {
            "Version": "2012-10-17",
            "Statement": [{
              "Action": [
                "s3:GetObject"
              ],
              "Effect": "Allow",
              "Principal": {
                "AWS": [
                  "*"
                ]
              },
              "Resource": [
                "arn:aws:s3:::outline/*"
              ],
              "Sid": ""
            }]
          }
        EOF
        destination = "/local/minio_policy.json"
      }
    }

    task "create-minio-data-folder" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "raw_exec"
      
      config {
        command = "sh"
        args = ["-c", "mkdir -p [[.outline.minio_task_volume_path]] && chown 1001:1001 [[.outline.minio_task_volume_path]]"]
      }

      resources {
        cpu    = [[ .outline.minio_data_folder_task_resources.cpu ]]
        memory = [[ .outline.minio_data_folder_task_resources.memory ]]
      }
    }

    task "minio-apply-policy" {
      lifecycle {
        hook = "poststart"
        sidecar = false
      }

      driver = "raw_exec"
      
      config {
        command = "sh"
        args = ["-c", "sleep 60s && docker exec $(docker ps -aqf 'name=^outline-minio') mc policy set-json /local/minio_policy.json local/outline"]
      }

      resources {
        cpu    = [[ .outline.minio_apply_policy_task_resources.cpu ]]
        memory = [[ .outline.minio_apply_policy_task_resources.memory ]]
      }
    }
  }

  group "outline-redis" {
    count = 1

    network {
      mode = "bridge"
    }

    update {
      min_healthy_time  = [[ .outline.redis_group_update.min_healthy_time | quote ]]
      healthy_deadline  = [[ .outline.redis_group_update.healthy_deadline | quote ]]
      progress_deadline = [[ .outline.redis_group_update.progress_deadline | quote ]]
      auto_revert       = [[ .outline.redis_group_update.auto_revert ]]
    }

    service {
      name = [[ .outline.redis_group_consul_service_name | quote ]]
      port = [[ .outline.redis_group_consul_service_port | quote ]]
      tags = [ [[ range $idx, $tag := .outline.redis_group_consul_tags ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]

      connect {
        sidecar_service {}
      }
    }

    restart {
      attempts = [[ .outline.redis_group_restart_attempts ]]
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "outline-redis" {
      driver = "docker"
      user = 1001

      config {
        image = [[.outline.redis_task_image | quote]]
        volumes = [
          "[[.outline.redis_task_volume_path]]:/bitnami/redis/data",
        ]
      }

      [[- $redis_task_env_vars_length := len .outline.redis_task_env_vars ]]
      [[- if not (eq $redis_task_env_vars_length 0) ]]
      env {
        [[- range $var := .outline.redis_task_env_vars ]]
        [[ $var.key ]] = [[ $var.value | quote ]]
        [[- end ]]
      }
      [[- end ]]

      resources {
        cpu    = [[ .outline.redis_task_resources.cpu ]]
        memory = [[ .outline.redis_task_resources.memory ]]
      }
    }

    task "create-redis-data-folder" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "raw_exec"
      
      config {
        command = "sh"
        args = ["-c", "mkdir -p [[.outline.redis_task_volume_path]] && chown 1001:1001 [[.outline.redis_task_volume_path]]"]
      }

      resources {
        cpu    = [[ .outline.redis_data_folder_task_resources.cpu ]]
        memory = [[ .outline.redis_data_folder_task_resources.memory ]]
      }
    }
  }

  group "outline" {
    count = 1

    network {
      mode = "bridge"
      [[- range $port := .outline.outline_group_network ]]
      port [[ $port.name | quote ]] {
        to = [[ $port.port ]]
      }
      [[- end ]]
    }

    update {
      min_healthy_time  = [[ .outline.outline_group_update.min_healthy_time | quote ]]
      healthy_deadline  = [[ .outline.outline_group_update.healthy_deadline | quote ]]
      progress_deadline = [[ .outline.outline_group_update.progress_deadline | quote ]]
      auto_revert       = [[ .outline.outline_group_update.auto_revert ]]
    }

    service {
      name = [[ .outline.outline_group_consul_service_name | quote ]]
      port = [[ .outline.outline_group_consul_service_port | quote ]]
      tags = [ [[ range $idx, $tag := .outline.outline_group_consul_tags ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]

      connect {
        sidecar_service {
          proxy {
            [[- range $upstream := .outline.outline_group_upstreams ]]
            upstreams {
              destination_name = [[ $upstream.name | quote ]]
              local_bind_port  = [[ $upstream.port ]]
            }
            [[- end ]]
          }
        }
      }
    }

    restart {
      attempts = [[ .outline.outline_group_restart_attempts ]]
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "outline" {
      driver = "docker"

      config {
        image = [[.outline.outline_task_image | quote]]
        command = "sh"
        args = ["-c", "yarn db:migrate --env=production-ssl-disabled && yarn start --env=production-ssl-disabled"]
      }

      [[- $outline_task_env_vars_length := len .outline.outline_task_env_vars ]]
      [[- if not (eq $outline_task_env_vars_length 0) ]]
      env {
        [[- range $var := .outline.outline_task_env_vars ]]
        [[ $var.key ]] = [[ $var.value | quote ]]
        [[- end ]]
      }
      [[- end ]]

      resources {
        cpu    = [[ .outline.outline_task_resources.cpu ]]
        memory = [[ .outline.outline_task_resources.memory ]]
      }
    }
  }
}
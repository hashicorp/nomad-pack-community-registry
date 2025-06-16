job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [ [[ range $idx, $dc := var "datacenters" . ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]
  type = "service"

  [[ if var "constraints" . ]][[ range $idx, $constraint := var "constraints" . ]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    value     = [[ $constraint.value | quote ]]
    [[- if ne $constraint.operator "" ]]
    operator  = [[ $constraint.operator | quote ]]
    [[- end ]]
  }
  [[- end ]][[- end ]]

  group "outline-postgresql" {
    count = 1

    network {
      mode = "bridge"
    }

    update {
      min_healthy_time  = [[ var "postgresql_group_update.min_healthy_time" . | quote ]]
      healthy_deadline  = [[ var "postgresql_group_update.healthy_deadline" . | quote ]]
      progress_deadline = [[ var "postgresql_group_update.progress_deadline" . | quote ]]
      auto_revert       = [[ var "postgresql_group_update.auto_revert" . ]]
    }

    service {
      name = [[ var "postgresql_group_consul_service_name" . | quote ]]
      port = [[ var "postgresql_group_consul_service_port" . | quote ]]
      tags = [ [[ range $idx, $tag := var "postgresql_group_consul_tags" . ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]

      connect {
        sidecar_service {}
      }
    }

    restart {
      attempts = [[ var "postgresql_group_restart_attempts" . ]]
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "outline-postgresql" {
      driver = "docker"
      user = 1001

      config {
        image = [[var "postgresql_task_image" . | quote]]
        volumes = [
          "[[var "postgresql_task_volume_path" .]]:/bitnami/postgresql",
        ]
      }

      [[- $postgresql_task_env_vars_length := len (var "postgresql_task_env_vars" .) ]]
      [[- if not (eq $postgresql_task_env_vars_length 0) ]]
      env {
        [[- range $var := var "postgresql_task_env_vars" . ]]
        [[ $var.key ]] = [[ $var.value | quote ]]
        [[- end ]]
      }
      [[- end ]]

      resources {
        cpu    = [[ var "postgresql_task_resources.cpu" . ]]
        memory = [[ var "postgresql_task_resources.memory" . ]]
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
        args = ["-c", "mkdir -p [[var "postgresql_task_volume_path" .]] && chown 1001:1001 [[var "postgresql_task_volume_path" .]]"]
      }

      resources {
        cpu    = [[ var "postgresql_data_folder_task_resources.cpu" . ]]
        memory = [[ var "postgresql_data_folder_task_resources.memory" . ]]
      }
    }
  }

  group "outline-minio" {
    count = 1

    network {
      mode = "bridge"
      [[- range $port := var "minio_group_network" . ]]
      port [[ $port.name | quote ]] {
        to = [[ $port.port ]]
        static = [[ $port.port ]]
      }
      [[- end ]]
    }

    update {
      min_healthy_time  = [[ var "minio_group_update.min_healthy_time" . | quote ]]
      healthy_deadline  = [[ var "minio_group_update.healthy_deadline" . | quote ]]
      progress_deadline = [[ var "minio_group_update.progress_deadline" . | quote ]]
      auto_revert       = [[ var "minio_group_update.auto_revert" . ]]
    }

    service {
      name = [[ var "minio_group_consul_service_name" . | quote ]]
      port = [[ var "minio_group_consul_service_port" . | quote ]]
      tags = [ [[ range $idx, $tag := var "minio_group_consul_tags" . ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]

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
      attempts = [[ var "minio_group_restart_attempts" . ]]
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "outline-minio" {
      driver = "docker"
      user = 1001

      config {
        image = [[var "minio_task_image" . | quote]]
        volumes = [
          "[[var "minio_task_volume_path" .]]:/data",
        ]
      }

      [[- $minio_task_env_vars_length := len (var "minio_task_env_vars" .) ]]
      [[- if not (eq $minio_task_env_vars_length 0) ]]
      env {
        [[- range $var := var "minio_task_env_vars" . ]]
        [[ $var.key ]] = [[ $var.value | quote ]]
        [[- end ]]
      }
      [[- end ]]

      resources {
        cpu    = [[ var "minio_task_resources.cpu" . ]]
        memory = [[ var "minio_task_resources.memory" . ]]
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
        args = ["-c", "mkdir -p [[var "minio_task_volume_path" .]] && chown 1001:1001 [[var "minio_task_volume_path" .]]"]
      }

      resources {
        cpu    = [[ var "minio_data_folder_task_resources.cpu" . ]]
        memory = [[ var "minio_data_folder_task_resources.memory" . ]]
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
        cpu    = [[ var "minio_apply_policy_task_resources.cpu" . ]]
        memory = [[ var "minio_apply_policy_task_resources.memory" . ]]
      }
    }
  }

  group "outline-redis" {
    count = 1

    network {
      mode = "bridge"
    }

    update {
      min_healthy_time  = [[ var "redis_group_update.min_healthy_time" . | quote ]]
      healthy_deadline  = [[ var "redis_group_update.healthy_deadline" . | quote ]]
      progress_deadline = [[ var "redis_group_update.progress_deadline" . | quote ]]
      auto_revert       = [[ var "redis_group_update.auto_revert" . ]]
    }

    service {
      name = [[ var "redis_group_consul_service_name" . | quote ]]
      port = [[ var "redis_group_consul_service_port" . | quote ]]
      tags = [ [[ range $idx, $tag := var "redis_group_consul_tags" . ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]

      connect {
        sidecar_service {}
      }
    }

    restart {
      attempts = [[ var "redis_group_restart_attempts" . ]]
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "outline-redis" {
      driver = "docker"
      user = 1001

      config {
        image = [[var "redis_task_image" . | quote]]
        volumes = [
          "[[var "redis_task_volume_path" .]]:/bitnami/redis/data",
        ]
      }

      [[- $redis_task_env_vars_length := len (var "redis_task_env_vars" .) ]]
      [[- if not (eq $redis_task_env_vars_length 0) ]]
      env {
        [[- range $var := var "redis_task_env_vars" . ]]
        [[ $var.key ]] = [[ $var.value | quote ]]
        [[- end ]]
      }
      [[- end ]]

      resources {
        cpu    = [[ var "redis_task_resources.cpu" . ]]
        memory = [[ var "redis_task_resources.memory" . ]]
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
        args = ["-c", "mkdir -p [[var "redis_task_volume_path" .]] && chown 1001:1001 [[var "redis_task_volume_path" .]]"]
      }

      resources {
        cpu    = [[ var "redis_data_folder_task_resources.cpu" . ]]
        memory = [[ var "redis_data_folder_task_resources.memory" . ]]
      }
    }
  }

  group "outline" {
    count = 1

    network {
      mode = "bridge"
      [[- range $port := var "outline_group_network" . ]]
      port [[ $port.name | quote ]] {
        to = [[ $port.port ]]
      }
      [[- end ]]
    }

    update {
      min_healthy_time  = [[ var "outline_group_update.min_healthy_time" . | quote ]]
      healthy_deadline  = [[ var "outline_group_update.healthy_deadline" . | quote ]]
      progress_deadline = [[ var "outline_group_update.progress_deadline" . | quote ]]
      auto_revert       = [[ var "outline_group_update.auto_revert" . ]]
    }

    service {
      name = [[ var "outline_group_consul_service_name" . | quote ]]
      port = [[ var "outline_group_consul_service_port" . | quote ]]
      tags = [ [[ range $idx, $tag := var "outline_group_consul_tags" . ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]

      connect {
        sidecar_service {
          proxy {
            [[- range $upstream := var "outline_group_upstreams" . ]]
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
      attempts = [[ var "outline_group_restart_attempts" . ]]
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "outline" {
      driver = "docker"

      config {
        image = [[var "outline_task_image" . | quote]]
        command = "sh"
        args = ["-c", "yarn db:migrate --env=production-ssl-disabled && yarn start --env=production-ssl-disabled"]
      }

      [[- $outline_task_env_vars_length := len (var "outline_task_env_vars" .) ]]
      [[- if not (eq $outline_task_env_vars_length 0) ]]
      env {
        [[- range $var := var "outline_task_env_vars" . ]]
        [[ $var.key ]] = [[ $var.value | quote ]]
        [[- end ]]
      }
      [[- end ]]

      resources {
        cpu    = [[ var "outline_task_resources.cpu" . ]]
        memory = [[ var "outline_task_resources.memory" . ]]
      }
    }
  }
}
job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [ [[ range $idx, $dc := var "datacenters" . ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]
  type = "service"

  group "mariadb" {
    count = 1

    network {
      mode = "bridge"
    }

    update {
      min_healthy_time  = [[ var "mariadb_group_update.min_healthy_time" . | quote ]]
      healthy_deadline  = [[ var "mariadb_group_update.healthy_deadline" . | quote ]]
      progress_deadline = [[ var "mariadb_group_update.progress_deadline" . | quote ]]
      auto_revert       = [[ var "mariadb_group_update.auto_revert" . ]]
    }

    volume "mariadb" {
      type = "host"
      read_only = false
      source = [[ var "mariadb_group_volume" . | quote ]]
    }

    [[- if var "mariadb_group_register_consul_service" . ]]
    service {
      name = [[ var "mariadb_group_consul_service_name" . | quote ]]
      port = [[ var "mariadb_group_consul_service_port" . | quote ]]
      tags = [ [[ range $idx, $tag := var "mariadb_group_consul_tags" . ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]

      connect {
        sidecar_service {}
      }

      [[- if var "mariadb_group_has_health_check" . ]]
      check {
        name     = "mariadb"
        type     = "tcp"
        port     = [[ var "mariadb_group_health_check.port" . ]]
        interval = [[ var "mariadb_group_health_check.interval" . | quote ]]
        timeout  = [[ var "mariadb_group_health_check.timeout" . | quote ]]
      }
      [[- end ]]
    }
    [[- end ]]

    restart {
      attempts = [[ var "mariadb_group_restart_attempts" . ]]
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "mariadb" {
      driver = "docker"

      config {
        image = [[ var "mariadb_task_image" . | quote]]
      }

      volume_mount {
        volume      = "mariadb"
        destination = "/var/lib/mysql"
        read_only   = false
      }

      [[- $mariadb_task_env_vars_length := len (var "mariadb_task_env_vars" .) ]]
      [[- if not (eq $mariadb_task_env_vars_length 0) ]]
      env {
        [[- range $var := var "mariadb_task_env_vars" . ]]
        [[ $var.key ]] = [[ $var.value | quote ]]
        [[- end ]]
      }
      [[- end ]]

      resources {
        cpu    = [[ var "mariadb_task_resources.cpu" . ]]
        memory = [[ var "mariadb_task_resources.memory" . ]]
      }
    }
  }

  group "wordpress" {
    count = 1

    network {
      mode = "bridge"
      [[- range $port := var "wordpress_group_network" . ]]
      port [[ $port.name | quote ]] {
        to = [[ $port.port ]]
      }
      [[- end ]]
    }

    update {
      min_healthy_time  = [[ var "wordpress_group_update.min_healthy_time" . | quote ]]
      healthy_deadline  = [[ var "wordpress_group_update.healthy_deadline" . | quote ]]
      progress_deadline = [[ var "wordpress_group_update.progress_deadline" . | quote ]]
      auto_revert       = [[ var "wordpress_group_update.auto_revert" . ]]
    }

    [[- if var "wordpress_group_register_consul_service" . ]]
    service {
      name = [[ var "wordpress_group_consul_service_name" . | quote ]]
      port = [[ var "wordpress_group_consul_service_port" . | quote ]]
      tags = [ [[ range $idx, $tag := var "wordpress_group_consul_tags" . ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]

      connect {
        sidecar_service {
          proxy {
            [[- range $upstream := var "wordpress_group_upstreams" . ]]
            upstreams {
              destination_name = [[ $upstream.name | quote ]]
              local_bind_port  = [[ $upstream.port ]]
            }
            [[- end ]]
          }
        }
      }

      [[- if var "wordpress_group_has_health_check" . ]]
      check {
        name     = [[ var "wordpress_group_health_check.name" . | quote ]]
        type     = "http"
        port     = [[ var "wordpress_group_health_check.port" . | quote ]]
        path     = [[ var "wordpress_group_health_check.path" . | quote ]]
        interval = [[ var "wordpress_group_health_check.interval" . | quote ]]
        timeout  = [[ var "wordpress_group_health_check.timeout" . | quote ]]
      }
      [[- end ]]
    }
    [[- end ]]

    restart {
      attempts = [[ var "wordpress_group_restart_attempts" . ]]
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "wordpress" {
      driver = "docker"

      config {
        image = [[ var "wordpress_task_image" . | quote]]
      }

      [[- $wordpress_task_env_vars_length := len (var "wordpress_task_env_vars" .) ]]
      [[- if not (eq $wordpress_task_env_vars_length 0) ]]
      env {
        [[- range $var := var "wordpress_task_env_vars" . ]]
        [[ $var.key ]] = [[ $var.value | quote ]]
        [[- end ]]
      }
      [[- end ]]

      resources {
        cpu    = [[ var "wordpress_task_resources.cpu" . ]]
        memory = [[ var "wordpress_task_resources.memory" . ]]
      }
    }
  }








  group "phpmyadmin" {
    count = 1

    network {
      mode = "bridge"
      [[- range $port := var "phpmyadmin_group_network" . ]]
      port [[ $port.name | quote ]] {
        to = [[ $port.port ]]
      }
      [[- end ]]
    }

    update {
      min_healthy_time  = [[ var "phpmyadmin_group_update.min_healthy_time" . | quote ]]
      healthy_deadline  = [[ var "phpmyadmin_group_update.healthy_deadline" . | quote ]]
      progress_deadline = [[ var "phpmyadmin_group_update.progress_deadline" . | quote ]]
      auto_revert       = [[ var "phpmyadmin_group_update.auto_revert" . ]]
    }

    [[- if var "phpmyadmin_group_register_consul_service" . ]]
    service {
      name = [[ var "phpmyadmin_group_consul_service_name" . | quote ]]
      port = [[ var "phpmyadmin_group_consul_service_port" . | quote ]]
      tags = [ [[ range $idx, $tag := var "phpmyadmin_group_consul_tags" . ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]

      connect {
        sidecar_service {
          proxy {
            [[- range $upstream := var "phpmyadmin_group_upstreams" . ]]
            upstreams {
              destination_name = [[ $upstream.name | quote ]]
              local_bind_port  = [[ $upstream.port ]]
            }
            [[- end ]]
          }
        }
      }

      [[- if var "phpmyadmin_group_has_health_check" . ]]
      check {
        name     = [[ var "phpmyadmin_group_health_check.name" . | quote ]]
        type     = "http"
        port     = [[ var "phpmyadmin_group_health_check.port" . | quote ]]
        path     = [[ var "phpmyadmin_group_health_check.path" . | quote ]]
        interval = [[ var "phpmyadmin_group_health_check.interval" . | quote ]]
        timeout  = [[ var "phpmyadmin_group_health_check.timeout" . | quote ]]
      }
      [[- end ]]
    }
    [[- end ]]

    restart {
      attempts = [[ var "phpmyadmin_group_restart_attempts" . ]]
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "phpmyadmin" {
      driver = "docker"

      config {
        image = [[ var "phpmyadmin_task_image" . | quote]]
      }

      [[- $phpmyadmin_task_env_vars_length := len (var "phpmyadmin_task_env_vars" .) ]]
      [[- if not (eq $phpmyadmin_task_env_vars_length 0) ]]
      env {
        [[- range $var := var "phpmyadmin_task_env_vars" . ]]
        [[ $var.key ]] = [[ $var.value | quote ]]
        [[- end ]]
      }
      [[- end ]]

      resources {
        cpu    = [[ var "phpmyadmin_task_resources.cpu" . ]]
        memory = [[ var "phpmyadmin_task_resources.memory" . ]]
      }
    }
  }
}

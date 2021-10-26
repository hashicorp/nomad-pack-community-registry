job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [ [[ range $idx, $dc := .wordpress.datacenters ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]
  type = "service"

  group "mariadb" {
    count = 1

    network {
      mode = "bridge"
    }

    update {
      min_healthy_time  = [[ .wordpress.mariadb_group_update.min_healthy_time | quote ]]
      healthy_deadline  = [[ .wordpress.mariadb_group_update.healthy_deadline | quote ]]
      progress_deadline = [[ .wordpress.mariadb_group_update.progress_deadline | quote ]]
      auto_revert       = [[ .wordpress.mariadb_group_update.auto_revert ]]
    }

    volume "mariadb" {
      type = "host"
      read_only = false
      source = [[ .wordpress.mariadb_group_volume | quote ]]
    }

    [[- if .wordpress.mariadb_group_register_consul_service ]]
    service {
      name = [[ .wordpress.mariadb_group_consul_service_name | quote ]]
      port = [[ .wordpress.mariadb_group_consul_service_port | quote ]]
      tags = [ [[ range $idx, $tag := .wordpress.mariadb_group_consul_tags ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]

      connect {
        sidecar_service {}
      }

      [[- if .wordpress.mariadb_group_has_health_check ]]
      check {
        name     = "mariadb"
        type     = "tcp"
        port     = [[ .wordpress.mariadb_group_health_check.port ]]
        interval = [[ .wordpress.mariadb_group_health_check.interval | quote ]]
        timeout  = [[ .wordpress.mariadb_group_health_check.timeout | quote ]]
      }
      [[- end ]]
    }
    [[- end ]]

    restart {
      attempts = [[ .wordpress.mariadb_group_restart_attempts ]]
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "mariadb" {
      driver = "docker"

      config {
        image = [[.wordpress.mariadb_task_image | quote]]
      }
      
      volume_mount {
        volume      = "mariadb"
        destination = "/var/lib/mysql"
        read_only   = false
      }

      [[- $mariadb_task_env_vars_length := len .wordpress.mariadb_task_env_vars ]]
      [[- if not (eq $mariadb_task_env_vars_length 0) ]]
      env {
        [[- range $var := .wordpress.mariadb_task_env_vars ]]
        [[ $var.key ]] = [[ $var.value | quote ]]
        [[- end ]]
      }
      [[- end ]]

      resources {
        cpu    = [[ .wordpress.mariadb_task_resources.cpu ]]
        memory = [[ .wordpress.mariadb_task_resources.memory ]]
      }
    }
  }

  group "wordpress" {
    count = 1

    network {
      mode = "bridge"
      [[- range $port := .wordpress.wordpress_group_network ]]
      port [[ $port.name | quote ]] {
        to = [[ $port.port ]]
      }
      [[- end ]]
    }

    update {
      min_healthy_time  = [[ .wordpress.wordpress_group_update.min_healthy_time | quote ]]
      healthy_deadline  = [[ .wordpress.wordpress_group_update.healthy_deadline | quote ]]
      progress_deadline = [[ .wordpress.wordpress_group_update.progress_deadline | quote ]]
      auto_revert       = [[ .wordpress.wordpress_group_update.auto_revert ]]
    }

    [[- if .wordpress.wordpress_group_register_consul_service ]]
    service {
      name = [[ .wordpress.wordpress_group_consul_service_name | quote ]]
      port = [[ .wordpress.wordpress_group_consul_service_port | quote ]]
      tags = [ [[ range $idx, $tag := .wordpress.wordpress_group_consul_tags ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]

      connect {
        sidecar_service {
          proxy {
            [[- range $upstream := .wordpress.wordpress_group_upstreams ]]
            upstreams {
              destination_name = [[ $upstream.name | quote ]]
              local_bind_port  = [[ $upstream.port ]]
            }
            [[- end ]]
          }
        }
      }

      [[- if .wordpress.wordpress_group_has_health_check ]]
      check {
        name     = [[ .wordpress.wordpress_group_health_check.name | quote ]]
        type     = "http"
        port     = [[ .wordpress.wordpress_group_health_check.port | quote ]]
        path     = [[ .wordpress.wordpress_group_health_check.path | quote ]]
        interval = [[ .wordpress.wordpress_group_health_check.interval | quote ]]
        timeout  = [[ .wordpress.wordpress_group_health_check.timeout | quote ]]
      }
      [[- end ]]
    }
    [[- end ]]

    restart {
      attempts = [[ .wordpress.wordpress_group_restart_attempts ]]
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "wordpress" {
      driver = "docker"

      config {
        image = [[.wordpress.wordpress_task_image | quote]]
      }

      [[- $wordpress_task_env_vars_length := len .wordpress.wordpress_task_env_vars ]]
      [[- if not (eq $wordpress_task_env_vars_length 0) ]]
      env {
        [[- range $var := .wordpress.wordpress_task_env_vars ]]
        [[ $var.key ]] = [[ $var.value | quote ]]
        [[- end ]]
      }
      [[- end ]]

      resources {
        cpu    = [[ .wordpress.wordpress_task_resources.cpu ]]
        memory = [[ .wordpress.wordpress_task_resources.memory ]]
      }
    }
  }








  group "phpmyadmin" {
    count = 1

    network {
      mode = "bridge"
      [[- range $port := .wordpress.phpmyadmin_group_network ]]
      port [[ $port.name | quote ]] {
        to = [[ $port.port ]]
      }
      [[- end ]]
    }

    update {
      min_healthy_time  = [[ .wordpress.phpmyadmin_group_update.min_healthy_time | quote ]]
      healthy_deadline  = [[ .wordpress.phpmyadmin_group_update.healthy_deadline | quote ]]
      progress_deadline = [[ .wordpress.phpmyadmin_group_update.progress_deadline | quote ]]
      auto_revert       = [[ .wordpress.phpmyadmin_group_update.auto_revert ]]
    }

    [[- if .wordpress.phpmyadmin_group_register_consul_service ]]
    service {
      name = [[ .wordpress.phpmyadmin_group_consul_service_name | quote ]]
      port = [[ .wordpress.phpmyadmin_group_consul_service_port | quote ]]
      tags = [ [[ range $idx, $tag := .wordpress.phpmyadmin_group_consul_tags ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]

      connect {
        sidecar_service {
          proxy {
            [[- range $upstream := .wordpress.phpmyadmin_group_upstreams ]]
            upstreams {
              destination_name = [[ $upstream.name | quote ]]
              local_bind_port  = [[ $upstream.port ]]
            }
            [[- end ]]
          }
        }
      }

      [[- if .wordpress.phpmyadmin_group_has_health_check ]]
      check {
        name     = [[ .wordpress.phpmyadmin_group_health_check.name | quote ]]
        type     = "http"
        port     = [[ .wordpress.phpmyadmin_group_health_check.port | quote ]]
        path     = [[ .wordpress.phpmyadmin_group_health_check.path | quote ]]
        interval = [[ .wordpress.phpmyadmin_group_health_check.interval | quote ]]
        timeout  = [[ .wordpress.phpmyadmin_group_health_check.timeout | quote ]]
      }
      [[- end ]]
    }
    [[- end ]]

    restart {
      attempts = [[ .wordpress.phpmyadmin_group_restart_attempts ]]
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "phpmyadmin" {
      driver = "docker"

      config {
        image = [[.wordpress.phpmyadmin_task_image | quote]]
      }

      [[- $phpmyadmin_task_env_vars_length := len .wordpress.phpmyadmin_task_env_vars ]]
      [[- if not (eq $phpmyadmin_task_env_vars_length 0) ]]
      env {
        [[- range $var := .wordpress.phpmyadmin_task_env_vars ]]
        [[ $var.key ]] = [[ $var.value | quote ]]
        [[- end ]]
      }
      [[- end ]]

      resources {
        cpu    = [[ .wordpress.phpmyadmin_task_resources.cpu ]]
        memory = [[ .wordpress.phpmyadmin_task_resources.memory ]]
      }
    }
  }
}

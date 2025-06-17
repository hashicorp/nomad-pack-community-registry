job [[ template "full_job_name" . ]] {

  region      = [[ var "region" . | quote ]]
  datacenters = [ [[ range $idx, $dc := var "datacenters" . ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]
  type        = "system"
  namespace   = [[ var "namespace" . | quote ]]
  [[ if var "constraints" . ]][[ range $idx, $constraint := var "constraints" . ]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    value     = [[ $constraint.value | quote ]]
    [[- if ne $constraint.operator "" ]]
    operator  = [[ $constraint.operator | quote ]]
    [[- end ]]
  }
  [[- end ]][[- end ]]

  group "vector" {
    count = 1

    network {
      mode = [[ var "vector_group_network.mode" . | quote ]]
      hostname = [[ var "vector_group_network.hostname" . | quote ]]
      [[- range $label, $to := var "vector_group_network.ports" . ]]
      port [[ $label | quote ]] {
        to = [[ $to ]]
      }
      [[- end ]]
    }

    update {
      min_healthy_time  = [[ var "vector_group_update.min_healthy_time" . | quote ]]
      healthy_deadline  = [[ var "vector_group_update.healthy_deadline" . | quote ]]
      progress_deadline = [[ var "vector_group_update.progress_deadline" . | quote ]]
      auto_revert       = [[ var "vector_group_update.auto_revert" . ]]
    }

    ephemeral_disk {
      migrate = [[ var "vector_group_ephemeral_disk.migrate" . ]]
      size    = [[ var "vector_group_ephemeral_disk.size" . ]]
      sticky  = [[ var "vector_group_ephemeral_disk.sticky" . ]]
    }

    task "vector" {
      driver = "docker"

      config {
        image = "timberio/vector:[[ var "vector_task.version" . ]]"

        ports = [ [[ range $label, $port := var "vector_group_network.ports" . ]][[if $label]][[ $label | quote ]],[[end]][[end]] ]

        mount {
          type = "bind"
          target = [[ var "vector_task_bind_mounts.target_procfs_root_path" . | quote ]]
          source = [[ var "vector_task_bind_mounts.source_procfs_root_path" . | quote ]]
          readonly = true
          bind_options {
            propagation = "rslave"
          }
        }

        mount {
          type = "bind"
          target = [[ var "vector_task_bind_mounts.target_sysfs_root_path" . | quote ]]
          source = [[ var "vector_task_bind_mounts.source_sysfs_root_path" . | quote ]]
          readonly = true
          bind_options {
            propagation = "rslave"
          }
        }

        mount {
          type = "bind"
          target = [[ var "vector_task_bind_mounts.target_docker_socket_path" . | quote ]]
          source = [[ var "vector_task_bind_mounts.source_docker_socket_path" . | quote ]]
          readonly = true
          bind_options {
            propagation = "rslave"
          }
        }
      }

      env {
        VECTOR_CONFIG      = "local/config/vector.toml"
        PROCFS_ROOT        = [[ var "vector_task_bind_mounts.target_procfs_root_path" . | quote ]]
        SYSFS_ROOT         = [[ var "vector_task_bind_mounts.target_sysfs_root_path" . | quote ]]
        DOCKER_SOCKET_PATH = [[ var "vector_task_bind_mounts.target_docker_socket_path" . | quote ]]
      }

[[- if ne (var "vector_task_data_config_toml" .) "" ]]
      template {
        data = <<EOH
[[ var "vector_task_data_config_toml" . ]]
EOH
        left_delimiter  = "(("
        right_delimiter = "))"
        change_mode     = "signal"
        change_signal   = "SIGHUP"
        destination     = "local/config/vector.toml"
      }
[[- end ]]

      template {
        data = <<EOH
      LOKI_ENDPOINT_URL = [[ var "vector_task_loki_prometheus.loki_endpoint_url" . | quote ]]
      LOKI_USERNAME     = [[ var "vector_task_loki_prometheus.loki_username" . | quote ]]
      LOKI_PASSWORD     = [[ var "vector_task_loki_prometheus.loki_password" . | quote ]]
      
      PROMETHEUS_ENDPOINT_URL = [[ var "vector_task_loki_prometheus.prometheus_endpoint_url" . | quote ]]
      PROMETHEUS_USERNAME     = [[ var "vector_task_loki_prometheus.prometheus_username" . | quote ]]
      PROMETHEUS_PASSWORD     = [[ var "vector_task_loki_prometheus.prometheus_password" . | quote ]]
      EOH

        destination = "secrets/loki_prometheus.env"
        env         = true
      }

      resources {
        cpu    = [[ var "vector_task_resources.cpu" . ]]
        memory = [[ var "vector_task_resources.memory" . ]]
      }

      [[- if var "vector_task_services" . ]]
      [[- range $idx, $service := var "vector_task_services" . ]]
      service {
        name = [[ $service.service_name | quote ]]
        port = [[ $service.service_port_label | quote ]]
        tags = [ [[ range $idx, $dc := $service.service_tags ]][[if $idx]],[[end]][[ $dc | quote ]][[end]] ]

        check {
          type     = "http"
          path     = [[ $service.check_path | quote ]]
          interval = [[ $service.check_interval | quote ]]
          timeout  = [[ $service.check_timeout | quote ]]
        }
      }
      [[- end ]]
      [[- end ]]
    }
  }
}

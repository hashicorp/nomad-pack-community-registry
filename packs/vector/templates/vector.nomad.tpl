job [[ template "full_job_name" . ]] {

  region      = [[ .vector.region | quote ]]
  datacenters = [ [[ range $idx, $dc := .vector.datacenters ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]
  type        = "system"
  namespace   = [[ .vector.namespace | quote ]]
  [[ if .vector.constraints ]][[ range $idx, $constraint := .vector.constraints ]]
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
      mode = [[ .vector.vector_group_network.mode | quote ]]
      hostname = [[ .vector.vector_group_network.hostname | quote ]]
      [[- range $label, $to := .vector.vector_group_network.ports ]]
      port [[ $label | quote ]] {
        to = [[ $to ]]
      }
      [[- end ]]
    }

    update {
      min_healthy_time  = [[ .vector.vector_group_update.min_healthy_time | quote ]]
      healthy_deadline  = [[ .vector.vector_group_update.healthy_deadline | quote ]]
      progress_deadline = [[ .vector.vector_group_update.progress_deadline | quote ]]
      auto_revert       = [[ .vector.vector_group_update.auto_revert ]]
    }

    ephemeral_disk {
      migrate = [[ .vector.vector_group_ephemeral_disk.migrate ]]
      size    = [[ .vector.vector_group_ephemeral_disk.size ]]
      sticky  = [[ .vector.vector_group_ephemeral_disk.sticky ]]
    }

    task "vector" {
      driver = "docker"

      config {
        image = "timberio/vector:[[ .vector.vector_task.version ]]"

        ports = [ [[ range $label, $port := .vector.vector_group_network.ports ]][[if $label]][[ $label | quote ]],[[end]][[end]] ]

        mount {
          type = "bind"
          target = [[ .vector.vector_task_bind_mounts.target_procfs_root_path | quote ]]
          source = [[ .vector.vector_task_bind_mounts.source_procfs_root_path | quote ]]
          readonly = true
          bind_options {
            propagation = "rslave"
          }
        }

        mount {
          type = "bind"
          target = [[ .vector.vector_task_bind_mounts.target_sysfs_root_path | quote ]]
          source = [[ .vector.vector_task_bind_mounts.source_sysfs_root_path | quote ]]
          readonly = true
          bind_options {
            propagation = "rslave"
          }
        }

        mount {
          type = "bind"
          target = [[ .vector.vector_task_bind_mounts.target_docker_socket_path | quote ]]
          source = [[ .vector.vector_task_bind_mounts.source_docker_socket_path | quote ]]
          readonly = true
          bind_options {
            propagation = "rslave"
          }
        }
      }

      env {
        VECTOR_CONFIG      = "local/config/vector.toml"
        PROCFS_ROOT        = [[ .vector.vector_task_bind_mounts.target_procfs_root_path | quote ]]
        SYSFS_ROOT         = [[ .vector.vector_task_bind_mounts.target_sysfs_root_path | quote ]]
        DOCKER_SOCKET_PATH = [[ .vector.vector_task_bind_mounts.target_docker_socket_path | quote ]]
      }

[[- if ne .vector.vector_task_data_config_toml "" ]]
      template {
        data = <<EOH
[[ .vector.vector_task_data_config_toml ]]
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
      LOKI_ENDPOINT_URL = [[ .vector.vector_task_loki_prometheus.loki_endpoint_url | quote ]]
      LOKI_USERNAME     = [[ .vector.vector_task_loki_prometheus.loki_username | quote ]]
      LOKI_PASSWORD     = [[ .vector.vector_task_loki_prometheus.loki_password | quote ]]
      
      PROMETHEUS_ENDPOINT_URL = [[ .vector.vector_task_loki_prometheus.prometheus_endpoint_url | quote ]]
      PROMETHEUS_USERNAME     = [[ .vector.vector_task_loki_prometheus.prometheus_username | quote ]]
      PROMETHEUS_PASSWORD     = [[ .vector.vector_task_loki_prometheus.prometheus_password | quote ]]
      EOH

        destination = "secrets/loki_prometheus.env"
        env         = true
      }

      resources {
        cpu    = [[ .vector.vector_task_resources.cpu ]]
        memory = [[ .vector.vector_task_resources.memory ]]
      }

      [[- if .vector.vector_task_services ]]
      [[- range $idx, $service := .vector.vector_task_services ]]
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

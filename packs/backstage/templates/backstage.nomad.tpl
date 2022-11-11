job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .backstage.datacenters  | toStringList ]]
  type = "service"

  group "backstage-postgresql" {
    count = 1

    network {
      mode = "host"
      [[- range $port := .backstage.postgresql_group_network ]]
      port [[ $port.name | quote ]] {
        to = [[ $port.port ]]
        static = [[ $port.port ]]
      }
      [[- end ]]
    }

    service {
      name = [[ .backstage.postgresql_group_nomad_service_name | quote ]]
      port = [[ .backstage.postgresql_group_nomad_service_port | quote ]]
      provider = "nomad"  
    }

    restart {
      attempts = [[ .backstage.postgresql_group_restart_attempts ]]
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    volume "backstage-postgres" {
      type      = "host"
      read_only = false
      source    = "backstage-postgres"
    }

    task "backstage-postgresql" {
      driver = "docker"

      config {
        image = [[.backstage.postgresql_task_image | quote]]
        ports = [[ .backstage.postgresql_group_nomad_service_port | list | toStringList ]]
      }

      volume_mount {
        volume      = "backstage-postgres"
        destination = "[[.backstage.postgresql_task_volume_path]]"
        read_only   = false
      }

      [[- $postgresql_task_env_vars_length := len .backstage.postgresql_task_env_vars ]]
      [[- if not (eq $postgresql_task_env_vars_length 0) ]]
      env {
        [[- range $var := .backstage.postgresql_task_env_vars ]]
        [[ $var.key ]] = [[ $var.value | quote ]]
        [[- end ]]
      }
      [[- end ]]

      resources {
        cpu    = [[ .backstage.postgresql_task_resources.cpu ]]
        memory = [[ .backstage.postgresql_task_resources.memory ]]
      }
    }
  }

  group "backstage" {
    count = 1

    network {
      mode = "host"
      [[- range $port := .backstage.backstage_group_network ]]
      port [[ $port.name | quote ]] {
        to = [[ $port.port ]]
        static = [[ $port.port ]]
      }
      [[- end ]]
    }

    service {
      name = [[ .backstage.backstage_group_nomad_service_name | quote ]]
      port = [[ .backstage.backstage_group_nomad_service_port | quote ]]
      provider = "nomad"  
    }

    restart {
      attempts = [[ .backstage.backstage_group_restart_attempts ]]
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "backstage" {
      driver = "docker"

      config {
        image = [[.backstage.backstage_task_image | quote]]
        ports = [[ .backstage.backstage_group_nomad_service_port | list | toStringList ]]
      }

      template {
        data        = <<EOH
{{ range nomadService [[ .backstage.postgresql_group_nomad_service_name | quote ]] }}
POSTGRES_HOST="{{ .Address }}"
POSTGRES_PORT="{{ .Port }}"
{{ end }}
EOH
        destination = "local/env.txt"
        env         = true
      }

      [[- $backstage_task_env_vars_length := len .backstage.backstage_task_env_vars ]]
      [[- if not (eq $backstage_task_env_vars_length 0) ]]
      env {
        [[- range $var := .backstage.backstage_task_env_vars ]]
        [[ $var.key ]] = [[ $var.value | quote ]]
        [[- end ]]
      }
      [[- end ]]

      resources {
        cpu    = [[ .backstage.backstage_task_resources.cpu ]]
        memory = [[ .backstage.backstage_task_resources.memory ]]
      }
    }
  }
}

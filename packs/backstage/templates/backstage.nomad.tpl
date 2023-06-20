job [[ .backstage.job_name | quote ]] {
  [[ template "region" . ]]
  datacenters = [[ .backstage.datacenters  | toStringList ]]
  type = "service"

  group "backstage-postgresql" {
    count = 1

    network {
      mode = "host"
      port "db" {
        to = 5432
        static = 5432
      }
    }

    service {
      name = [[ .backstage.postgresql_group_nomad_service_name | quote ]]
      port = "db"
      provider = "nomad"  
    }

    restart {
      attempts = 2
      interval = "10m"
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
        ports = ["db"]
      }

      volume_mount {
        volume      = "backstage-postgres"
        destination = "[[.backstage.postgresql_task_volume_path]]"
        read_only   = false
      }

      template {
        destination = "${NOMAD_SECRETS_DIR}/env.vars"
        env         = true
        change_mode = "restart"
        data        = <<EOF
{{- with nomadVar "nomad/jobs/[[ .backstage.job_name ]]" -}}
POSTGRES_USER = {{ .postgres_user }}
POSTGRES_PASSWORD = {{ .postgres_password }}
{{- end -}}
EOF
      }

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
      port "http" {
        to = 7007
        static = 7007
      }
    }

    service {
      name = [[ .backstage.backstage_group_nomad_service_name | quote ]]
      port = "http"
      provider = "nomad"  
    }

    restart {
      attempts = 2
      interval = "10m"
      delay = "15s"
      mode = "fail"
    }

    task "backstage" {
      driver = "docker"

      config {
        image = [[ .backstage.backstage_task_image | quote]]
        ports = ["http"]
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

      template {
        destination = "${NOMAD_SECRETS_DIR}/env.vars"
        env         = true
        change_mode = "restart"
        data        = <<EOF
{{- with nomadVar "nomad/jobs/[[ .backstage.job_name ]]" -}}
POSTGRES_USER = {{ .postgres_user }}
POSTGRES_PASSWORD = {{ .postgres_password }}
[[- $backstage_task_env_vars_length := len .backstage.backstage_task_nomad_vars ]]
  [[- if not (eq $backstage_task_env_vars_length 0) ]]
    [[- range $var := .backstage.backstage_task_nomad_vars ]]
[[ $var.key ]] = {{ .[[ $var.value ]] }}
    [[- end ]]
[[- end ]]
{{- end -}}
EOF
      }

      resources {
        cpu    = [[ .backstage.backstage_task_resources.cpu ]]
        memory = [[ .backstage.backstage_task_resources.memory ]]
      }
    }
  }
}

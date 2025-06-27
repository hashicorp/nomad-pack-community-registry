job [[ template "job_name" . ]] {

  [[ template "region" . ]]
  datacenters = [[ var "datacenters" . | toJson ]]
  namespace   = [[ var "namespace" . | quote ]]
  type        = "service"

  [[ template "constraints" var "constraints" . ]]

  group "nextcloud" {
    network {
      mode = [[ var "network.mode" . | quote ]]
      [[- range $port := var "network.ports" . ]]
      port [[ $port.name | quote ]] {
        to = [[ $port.to ]]
        [[- if $port.static ]]
        static = [[ $port.static ]]
        [[- end ]]
      }
      [[- end ]]
    }

    task "application" {
      driver = "docker"

      [[- if var "app_service" . ]]
      [[ template "service" var "app_service" . ]]
      [[- end ]]

      config {
        image = "nextcloud:[[ var "nextcloud_image_tag" . ]]"
        args = [[ var "container_args" . | toJson ]]

        [[- if gt (len (var "app_mounts" .)) 0 ]]
        [[ template "mounts" var "app_mounts" . ]]
        [[- end ]]
      }
      [[ template "resources" var "app_resources" . ]]

      env {
        [[- template "env_vars" var "env_vars" .]]

        [[- if var "include_database_task" . -]]
        [[template "env_vars" var "db_env_vars" .]]
        [[- end ]]
      }
    }

    [[ if var "include_database_task" . -]]
    task "database" {
      driver = "docker"

      [[- if var "db_service" . ]]
      [[ template "service" var "db_service" . ]]
      [[- end ]]

      config {
        image = "postgres:[[var "postgres_image_tag" .]]"

        [[- if gt (len (var "postgres_mounts" .)) 0 ]]
        [[ template "mounts" var "postgres_mounts" . ]]
        [[- end ]]
      }

      env {
        [[- template "env_vars" var "db_env_vars" .]]
        PGDATA="/appdata/postgres"
      }

      [[ template "resources" var "db_resources" . ]]
    }
    [[- end ]]

    [[ if var "prestart_directory_creation" . -]]
    task "create-data-dirs" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "raw_exec"

      config {
        command = "sh"
        args = ["-c", "mkdir -p [[var "db_volume_source_path" .]] && chown 1001:1001 [[var "db_volume_source_path" .]] && mkdir -p [[var "app_data_source_path" .]] && chown 1001:1001 [[var "app_data_source_path" .]]"]
      }

      resources {
        cpu    = 50
        memory = 50
      }
    }
    [[- end ]]
  }
}

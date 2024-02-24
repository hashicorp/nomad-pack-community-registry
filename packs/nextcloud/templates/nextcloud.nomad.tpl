job [[ template "job_name" . ]] {

  [[ template "region" . ]]
  datacenters = [[ .nextcloud.datacenters | toJson ]]
  node_pool = [[ .nextcloud.node_pool | quote ]]
  namespace   = [[ .nextcloud.namespace | quote ]]
  type        = "service"

  [[ template "constraints" .nextcloud.constraints ]]

  group "nextcloud" {
    network {
      mode = [[ .nextcloud.network.mode | quote ]]
      [[- range $port := .nextcloud.network.ports ]]
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

      [[- if .nextcloud.app_service ]]
      [[ template "service" .nextcloud.app_service ]]
      [[- end ]]

      config {
        image = "nextcloud:[[ .nextcloud.nextcloud_image_tag ]]"
        args = [[ .nextcloud.container_args | toJson ]]

        [[- if gt (len .nextcloud.app_mounts) 0 ]]
        [[ template "mounts" .nextcloud.app_mounts ]]
        [[- end ]]
      }
      [[ template "resources" .nextcloud.app_resources ]]

      env {
        [[- template "env_vars" .nextcloud.env_vars]]

        [[- if .nextcloud.include_database_task -]]
        [[template "env_vars" .nextcloud.db_env_vars]]
        [[- end ]]
      }
    }

    [[ if .nextcloud.include_database_task -]]
    task "database" {
      driver = "docker"

      [[- if .nextcloud.db_service ]]
      [[ template "service" .nextcloud.db_service ]]
      [[- end ]]

      config {
        image = "postgres:[[.nextcloud.postgres_image_tag]]"

        [[- if gt (len .nextcloud.postgres_mounts) 0 ]]
        [[ template "mounts" .nextcloud.postgres_mounts ]]
        [[- end ]]
      }

      env {
        [[- template "env_vars" .nextcloud.db_env_vars]]
        PGDATA="/appdata/postgres"
      }

      [[ template "resources" .nextcloud.db_resources ]]
    }
    [[- end ]]

    [[ if .nextcloud.prestart_directory_creation -]]
    task "create-data-dirs" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "raw_exec"

      config {
        command = "sh"
        args = ["-c", "mkdir -p [[.nextcloud.db_volume_source_path]] && chown 1001:1001 [[.nextcloud.db_volume_source_path]] && mkdir -p [[.nextcloud.app_data_source_path]] && chown 1001:1001 [[.nextcloud.app_data_source_path]]"]
      }

      resources {
        cpu    = 50
        memory = 50
      }
    }
    [[- end ]]
  }
}

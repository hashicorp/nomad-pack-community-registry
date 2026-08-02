[[ template "validate_deployment" . ]]

job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ var "datacenters" . | toStringList ]]
  namespace   = [[ var "namespace" . | quote ]]
  type        = "service"

[[ template "job_placement" . ]]

  [[- if eq (var "database_mode" .) "provision" ]]
  [[- if eq (var "count" .) 1 ]]
  group "nomatron" {
    count = 1

[[ template "group_vault_block" . ]]

[[ template "group_network" . ]]

    [[- $lbMode := var "load_balancer_mode" . -]]
    [[- if and (var "register_service" .) (or (eq $lbMode "service") (eq $lbMode "traefik")) ]]
[[ template "nomatron_service_block" . ]]
    [[- end ]]

    volume "postgres-data" {
      type      = "host"
      source    = [[ var "postgres.volume_path" . | quote ]]
      read_only = false
    }

    restart {
      attempts = 3
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

[[ template "postgres_task" . ]]

[[ template "nomatron_server_task" . ]]
  }
  [[- else ]]
  group "postgres" {
    count = 1

[[ template "postgres_group_network" . ]]

    volume "postgres-data" {
      type      = "host"
      source    = [[ var "postgres.volume_path" . | quote ]]
      read_only = false
    }

    restart {
      attempts = 3
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

[[ template "postgres_task" . ]]
  }

  group "nomatron-server" {
    count = [[ var "count" . ]]

    spread {
      attribute = "${node.unique.id}"
      weight    = 100
    }

[[ template "group_vault_block" . ]]

[[ template "group_network" . ]]

    [[- $lbMode := var "load_balancer_mode" . -]]
    [[- if and (var "register_service" .) (or (eq $lbMode "service") (eq $lbMode "traefik")) ]]
[[ template "nomatron_service_block" . ]]
    [[- end ]]

    update {
      max_parallel     = 1
      min_healthy_time = "30s"
      healthy_deadline = "5m"
      auto_revert      = true
    }

    restart {
      attempts = 3
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

[[ template "nomatron_server_task" . ]]
  }
  [[- end ]]
  [[- else ]]
  group "nomatron-server" {
    count = [[ var "count" . ]]

    [[- if gt (var "count" .) 1 ]]
    spread {
      attribute = "${node.unique.id}"
      weight    = 100
    }
    [[- end ]]

[[ template "group_vault_block" . ]]

[[ template "group_network" . ]]

    [[- $lbMode := var "load_balancer_mode" . -]]
    [[- if and (var "register_service" .) (or (eq $lbMode "service") (eq $lbMode "traefik")) ]]
[[ template "nomatron_service_block" . ]]
    [[- end ]]

    update {
      max_parallel     = 1
      min_healthy_time = "30s"
      healthy_deadline = "5m"
      auto_revert      = true
    }

    restart {
      attempts = 3
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

[[ template "nomatron_server_task" . ]]

    [[- if and (var "bootstrap.auto_init_database" .) (eq (var "database_mode" .) "byodb") (eq (var "count" .) 1) ]]
    task "database-init" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      [[- if eq (var "runtime" .) "docker" ]]
      driver = "docker"

      config {
        image   = "ghcr.io/nomatronio/nomatron-releases/nomatron:[[ var "nomatron_version" . ]]"
        command = "nomatron"
        args    = ["database", "init", "--config", "${NOMAD_TASK_DIR}/config/nomatron.hcl"]
      }
      [[- else if eq (var "binary_install_method" .) "artifact" ]]
      driver = "exec"

      artifact {
        source      = "https://github.com/nomatronio/nomatron-releases/releases/download/[[ var "nomatron_version" . ]]/nomatron_[[ trimPrefix "v" (var "nomatron_version" .) ]]_linux_[[ var "binary_arch" . ]].tar.gz"
        destination = "local/bin"
      }

      config {
        command = "[[ template "binary_artifact_command" . ]]"
        args    = ["database", "init", "--config", "${NOMAD_TASK_DIR}/config/nomatron.hcl"]
      }
      [[- else ]]
      driver = "exec"

      config {
        command = [[ var "binary_path" . | quote ]]
        args    = ["database", "init", "--config", "${NOMAD_TASK_DIR}/config/nomatron.hcl"]
      }
      [[- end ]]

      template {
        data = <<EOH
server {
  port = [[ var "server.port" . ]]
  api_addr = [[ if ne (var "server.api_addr" .) "" ]][[ var "server.api_addr" . | quote ]][[ else ]][[ printf "http://127.0.0.1:%v" (var "server.port" .) | quote ]][[ end ]]
}
database {
[[ template "nomatron_database_connection_hcl" . ]]
}
EOH
        destination = "local/config/nomatron.hcl"
      }

[[ template "nomatron_secrets_env_template" . ]]
      env {
[[- if eq (var "secrets_backend" .) "pack_vars" ]]
        NOMATRON_ENCRYPTION_KEY = [[ var "secrets.encryption_key" . | quote ]]
        NOMATRON_LICENSE_KEY    = [[ var "secrets.license_key" . | quote ]]
        NOMATRON_CLUSTER_KEY    = [[ var "secrets.cluster_key" . | quote ]]
[[ template "nomatron_db_url_env_pack_vars" . ]]
[[- end ]]
      }

      resources {
        cpu    = 250
        memory = 256
      }
    }
    [[- end ]]
  }
  [[- end ]]
}

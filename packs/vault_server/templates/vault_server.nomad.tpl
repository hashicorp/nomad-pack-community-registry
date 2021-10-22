job [[ template "full_job_name" . ]] {

  region      = [[ .vault_server.region | quote ]]
  datacenters = [ [[ range $idx, $dc := .vault_server.datacenters ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]
  namespace   = [[ .vault_server.namespace | quote ]]

  [[- if .vault_server.constraints ]]
  [[- range $idx, $constraint := .vault_server.constraints ]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    value     = [[ $constraint.value | quote ]]
    [[- if ne $constraint.operator "" ]]
    operator  = [[ $constraint.operator | quote ]]
    [[- end ]]
  }
  [[- end ]]
  [[- end ]]

  group "vault" {

    count = [[ .vault_server.vault_server_group_count ]]

    network {
      mode = [[ .vault_server.vault_server_group_network.mode | quote ]]
      [[- range $name, $portInfo := .vault_server.vault_server_group_network.ports ]]
      port [[ $name | quote ]] {
        to = [[ $portInfo ]]
      }
      [[- end ]]
    }

    task "vault_server" {
      driver = [[ .vault_server.vault_server_task.driver | quote ]]

      [[- if ( eq .vault_server.vault_server_task.driver "exec" ) ]]
      artifact {
        source      = [[ printf "\"https://releases.hashicorp.com/vault/%s/vault_%s_linux_amd64.zip\"" .vault_server.vault_server_task.version .vault_server.vault_server_task.version ]]
        destination = "/usr/local/bin"
      }
      [[- end ]]

      env {
              VAULT_DISABLE_MLOCK = true
            }

      config {
        [[- if ( eq .vault_server.vault_server_task.driver "exec" ) ]]
        command = "/usr/local/bin/vault"
        [[- end ]]
        [[- if ( eq .vault_server.vault_server_task.driver "docker" ) ]]
        image   = "hashicorp/vault:[[ .vault_server.vault_server_task.version ]]"
        command = "vault"
        [[- end ]]
        args  = [[ template "full_args" . ]]
      }

      [[- if ne .vault_server.vault_server_task_config "" ]]
      template {
        data = <<EOF
[[ .vault_server.vault_server_task_config ]]
EOF

        destination = "$${NOMAD_TASK_DIR}/config/config.hcl"
        change_mode = "noop"
      }
      [[- end ]]

      resources {
        cpu    = [[ .vault_server.vault_server_task_resources.cpu ]]
        memory = [[ .vault_server.vault_server_task_resources.memory ]]
      }
      [[ if .vault_server.vault_server_task_services ]]
      [[- range $idx, $service := .vault_server.vault_server_task_services ]]
      service {
        name = "[[ $service.service_name]]"
        port = [[ $service.service_port_label | quote ]]
        tags = [ [[ range $idx, $tag := $service.service_tags ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]

        [[- if $service.check_enabled ]]
        check {
          type     = [[ $service.check_type | quote ]]
          path     = [[ $service.check_path | quote ]]
          interval = [[ $service.check_interval | quote ]]
          timeout  = [[ $service.check_timeout | quote ]]
        }
        [[- end ]]
      }
      [[- end ]]
      [[- end ]]
    }
  }
}

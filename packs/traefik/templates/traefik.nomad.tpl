job [[ template "job_name" . ]] {

  region      = [[ var "region" . | quote]]
  datacenters = [[ var "datacenters" . | toStringList ]]
  type        = "system"
  [[ if var "constraints" . ]][[ range $idx, $constraint := var "constraints" . ]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    value     = [[ $constraint.value | quote ]]
    [[- if ne $constraint.operator "" ]]
    operator  = [[ $constraint.operator | quote ]]
    [[- end ]]
  }
  [[- end ]][[- end ]]

  group "traefik" {

    network {
      mode = [[ var "traefik_group_network.mode" . | quote ]]
      [[- if var "traefik_group_network.dns" . ]]
      dns {
      [[- range $label, $to := var "traefik_group_network.dns" . ]]
          [[ $label ]] = [[ $to | toPrettyJson ]]
      [[- end ]]
      }
      [[- end ]]
      [[- range $label, $to := var "traefik_group_network.ports" . ]]
      port [[ $label | quote ]] {
        static = [[ $to ]]
        to     = [[ $to ]]
      }
      [[- end ]]
    }


    [[- if var "traefik_vault" . ]]

    vault {
      policies = [[ var "traefik_vault" . | toStringList ]]
      change_mode   = "restart"
    }
    [[- end ]]

    task "traefik" {
      driver = [[ var "traefik_task.driver" . | quote ]]

      config {
        [[- if var "traefik_task.network_mode" . ]]
        network_mode = [[ var "traefik_task.network_mode" . | quote ]]
        [[- end ]]
        [[- if ( eq (var "traefik_task.driver" .) "docker" ) ]]
        image = "traefik:[[ var "traefik_task.version" . ]]"
        [[- if var "traefik_group_network.ports" . ]]
        [[- $ports := keys (var "traefik_group_network.ports" .) ]]
        ports = [[ $ports | toPrettyJson ]]
        [[- end ]]
        [[- end ]]

        [[- if ne (var "traefik_task_app_config" .) "" ]]
        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml",
        ]
        [[- end ]]
      }

    [[- if var "traefik_task_cacert" . ]]
      template {
        data = <<EOF
[[ var "traefik_task_cacert" . ]]
EOF
        destination = "/secrets/traefik_ca.crt"
      }
    [[- end ]]

    [[- if var "traefik_task_cert" . ]]
      template {
        data = <<EOF
[[ var "traefik_task_cert" . ]]
EOF
        destination = "/secrets/traefik_server.crt"
      }
    [[- end ]]

    [[- if var "traefik_task_cert_key" . ]]
      template {
        data = <<EOF
[[ var "traefik_task_cert_key" . ]]
EOF
        destination = "/secrets/traefik_server.key"
      }
    [[- end ]]

[[- if ne (var "traefik_task_app_config" .) "" ]]
      template {
        data = <<EOF
[[ var "traefik_task_app_config" . ]]
EOF

        destination = "local/traefik.toml"
      }
[[- end ]]

[[- if var "traefik_task_dynamic_config" . ]]
      template {
        data = <<EOF
[[ var "traefik_task_dynamic_config" . ]]
EOF

        destination = "local/traefik_dynamimc.toml"
        change_mode = "noop"
      }
[[- end ]]

      resources {
        cpu    = [[ var "traefik_task_resources.cpu" . ]]
        memory = [[ var "traefik_task_resources.memory" . ]]
      }
      [[ if var "traefik_task_services" . ]][[ range $idx, $service := var "traefik_task_services" . ]]
      service {
        name = [[ $service.service_name | quote ]]
        port = [[ $service.service_port_label | quote ]]

        [[- if $service.service_tags ]]
        tags = [[ $service.service_tags | toPrettyJson ]]
        [[- end ]]

        [[- if $service.check_enabled ]]
        check {
          type     = [[ $service.check_type | quote ]]
          [[- if $service.check_path ]]
          path     = [[ $service.check_path | quote ]]
          [[- end ]]
          interval = [[ $service.check_interval | quote ]]
          timeout  = [[ $service.check_timeout | quote ]]
        }
        [[- end ]]
      }
      [[- end ]][[ end ]]
    }
  }
}

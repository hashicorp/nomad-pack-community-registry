job [[ template "job_name" . ]] {

  region      = [[ .traefik.region | quote]]
  datacenters = [[ .traefik.datacenters | toStringList ]]
  node_pool = [[ .traefik.node_pool | quote ]]
  type        = "system"
  [[ if .traefik.constraints ]][[ range $idx, $constraint := .traefik.constraints ]]
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
      mode = [[ .traefik.traefik_group_network.mode | quote ]]
      [[- if .traefik.traefik_group_network.dns ]]
      dns {
      [[- range $label, $to := .traefik.traefik_group_network.dns ]]
          [[ $label ]] = [[ $to | toPrettyJson ]]
      [[- end ]]
      }
      [[- end ]]
      [[- range $label, $to := .traefik.traefik_group_network.ports ]]
      port [[ $label | quote ]] {
        static = [[ $to ]]
        to     = [[ $to ]]
      }
      [[- end ]]
    }


    [[- if .traefik.traefik_vault ]]

    vault {
      policies = [[ .traefik.traefik_vault | toStringList ]]
      change_mode   = "restart"
    }
    [[- end ]]

    task "traefik" {
      driver = [[ .traefik.traefik_task.driver | quote ]]

      config {
        [[- if .traefik.traefik_task.network_mode ]]
        network_mode = [[ .traefik.traefik_task.network_mode | quote ]]
        [[- end ]]
        [[- if ( eq .traefik.traefik_task.driver "docker" ) ]]
        image = "traefik:[[ .traefik.traefik_task.version ]]"
        [[- if .traefik.traefik_group_network.ports ]]
        [[- $ports := keys .traefik.traefik_group_network.ports ]]
        ports = [[ $ports | toPrettyJson ]]
        [[- end ]]
        [[- end ]]

        [[- if ne .traefik.traefik_task_app_config "" ]]
        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml",
        ]
        [[- end ]]
      }

    [[- if .traefik.traefik_task_cacert ]]
      template {
        data = <<EOF
[[ .traefik.traefik_task_cacert ]]
EOF
        destination = "/secrets/traefik_ca.crt"
      }
    [[- end ]]

    [[- if .traefik.traefik_task_cert ]]
      template {
        data = <<EOF
[[ .traefik.traefik_task_cert ]]
EOF
        destination = "/secrets/traefik_server.crt"
      }
    [[- end ]]

    [[- if .traefik.traefik_task_cert_key ]]
      template {
        data = <<EOF
[[ .traefik.traefik_task_cert_key ]]
EOF
        destination = "/secrets/traefik_server.key"
      }
    [[- end ]]

[[- if ne .traefik.traefik_task_app_config "" ]]
      template {
        data = <<EOF
[[ .traefik.traefik_task_app_config ]]
EOF

        destination = "local/traefik.toml"
      }
[[- end ]]

[[- if .traefik.traefik_task_dynamic_config ]]
      template {
        data = <<EOF
[[ .traefik.traefik_task_dynamic_config ]]
EOF

        destination = "local/traefik_dynamimc.toml"
        change_mode = "noop"
      }
[[- end ]]

      resources {
        cpu    = [[ .traefik.traefik_task_resources.cpu ]]
        memory = [[ .traefik.traefik_task_resources.memory ]]
      }
      [[ if .traefik.traefik_task_services ]][[ range $idx, $service := .traefik.traefik_task_services ]]
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

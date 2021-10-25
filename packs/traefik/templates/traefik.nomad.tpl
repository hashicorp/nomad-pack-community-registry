job [[ template "job_name" . ]] {

  region      = [[ .traefik.region | quote]]
  datacenters = [[ .traefik.datacenters | toPrettyJson ]]
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
      [[- range $label, $to := .traefik.traefik_group_network.ports ]]
      port [[ $label | quote ]] {
        static = [[ $to ]]
        to     = [[ $to ]]
      }
      [[- end ]]
    }

    task "traefik" {
      driver = [[ .traefik.traefik_task.driver | quote ]]

      config {
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

[[- if ne .traefik.traefik_task_app_config "" ]]
      template {
        data = <<EOF
[[ .traefik.traefik_task_app_config ]]
EOF

        destination = "local/traefik.toml"
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

        [[- if $service.check_enabled ]]
        check {
          type     = [[ $service.check_type | quote ]]
          path     = [[ $service.check_path | quote ]]
          interval = [[ $service.check_interval | quote ]]
          timeout  = [[ $service.check_timeout | quote ]]
        }
        [[- end ]]
      }
      [[- end ]][[ end ]]
    }
  }
}

job [[ template "full_job_name" . ]] {
  [[ template "region" . ]]

  datacenters = [[ var "datacenters" . | toStringList ]]
  namespace   = [[ var "namespace" . | quote ]]

  type = [[ var "job_type" . | quote ]]

  [[ if var "constraints" . ]][[ range $idx, $constraint := var "constraints" . ]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    value     = [[ $constraint.value | quote ]]
    [[- if ne $constraint.operator "" ]]
    operator  = [[ $constraint.operator | quote ]]
    [[- end ]]
  }
  [[- end ]][[- end ]]

  group "otel-collector" {
    [[- if eq (var "job_type" .) "service" ]]
    count = [[ var "instance_count" . ]]
    [[- end ]]
    network {
      mode = [[ var "network_config.mode" . | quote ]]
      [[- range $label, $to := var "network_config.ports" . ]]
      port [[ $label | quote ]] {
        to = [[ $to ]]
      }
      [[- end ]]
    }

    [[ template "vault_config" . ]]

    task "otel-collector" {
      driver = "docker"

      config {
        image = "[[ var "task_config.image" . ]]:[[ var "task_config.version" . ]]"
        entrypoint = [
          "/otelcol-contrib",
          "--config=[[ var "config_yaml_location" . ]]",
        ]


        [[- if var "privileged_mode" . ]]
        pid_mode   = "host"
        privileged = true
        [[- end ]]

        ports = [[ keys (var "network_config.ports" .) | toPrettyJson ]]

        volumes = [
          "[[ var "config_yaml_location" . ]]:/etc/otel/config.yaml",
          [[- if var "privileged_mode" . ]]
          "/:/hostfs:ro,rslave",
          [[- end ]]
        ]

      }

      [[ template "env_vars" . ]]

      template {
        data = <<EOH
[[ var "config_yaml" . ]]
EOH

        change_mode   = "restart"
        destination   = "[[ var "config_yaml_location" . ]]"
      }

      [[ template "additional_templates" . ]]

      resources {
        cpu    = [[ var "resources.cpu" . ]]
        memory = [[ var "resources.memory" . ]]
      }

      [[- if var "task_services" . ]]
      [[- $traefik_config := var "traefik_config" . -]]
      [[ range $idx, $service := var "task_services" . ]]
      service {
        name = [[ $service.service_name | quote ]]
        port = [[ $service.service_port_label | quote ]]
        tags = [[ template "traefik_service_tags" (dict "traefik_config" $traefik_config "service" $service) ]]
        [[- if $service.check_enabled ]]
        check {
          type     = "http"
          path     = [[ $service.check_path | quote ]]
          interval = [[ $service.check_interval | quote ]]
          timeout  = [[ $service.check_timeout | quote ]]
        }
        [[- end ]]
      }
      [[ end ]]
      [[- end ]]
    }
  }
}

[[- $vars := .opentelemetry_collector -]]
job [[ template "full_job_name" . ]] {
  [[ template "region" . ]]

  datacenters = [[ $vars.datacenters | toStringList ]]
  namespace   = [[ $vars.namespace | quote ]]

  type = [[ $vars.job_type | quote ]]

  [[ if $vars.constraints ]][[ range $idx, $constraint := $vars.constraints ]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    value     = [[ $constraint.value | quote ]]
    [[- if ne $constraint.operator "" ]]
    operator  = [[ $constraint.operator | quote ]]
    [[- end ]]
  }
  [[- end ]][[- end ]]

  group "otel-collector" {
    [[- if eq $vars.job_type "service" ]]
    count = [[ $vars.instance_count ]]
    [[- end ]]
    network {
      mode = [[ $vars.network_config.mode | quote ]]
      [[- range $label, $to := $vars.network_config.ports ]]
      port [[ $label | quote ]] {
        to = [[ $to ]]
      }
      [[- end ]]
    }

    [[ template "vault_config" . ]]

    task "otel-collector" {
      driver = "docker"

      config {
        image = "[[ $vars.task_config.image ]]:[[ $vars.task_config.version ]]"
        force_pull = true
        entrypoint = [
          "/otelcol-contrib",
          "--config=[[ $vars.config_yaml_location ]]",
        ]


        [[- if $vars.privileged_mode ]]
        pid_mode   = "host"
        privileged = true
        [[- end ]]

        ports = [[ keys $vars.network_config.ports | toPrettyJson ]]

        [[ if $vars.use_volumes ]]
        volumes = [
          "[[ $vars.config_yaml_location ]]:/etc/otel/config.yaml",
          [[- if $vars.privileged_mode ]]
          "/:/hostfs:ro,rslave",
          [[- end ]]
        ]
        [[- end ]]

      }

      [[ template "env_vars" . ]]

      template {
        data = <<EOH
[[ $vars.config_yaml ]]
EOH

        change_mode   = "restart"
        destination   = "[[ $vars.config_yaml_location ]]"
      }

      [[ template "additional_templates" . ]]

      resources {
        cpu    = [[ $vars.resources.cpu ]]
        memory = [[ $vars.resources.memory ]]
      }

      [[- if $vars.task_services ]]
      [[- range $idx, $service := $vars.task_services ]]
      [[- if or (not ($vars.traefik_config.enabled)) (and ($vars.traefik_config.enabled) (ne $service.service_port_label "otlphttp") (ne $service.service_port_label "otlp")) ]]
      service {
        name = [[ $service.service_name | quote ]]
        port = [[ $service.service_port_label | quote ]]
        tags = [[ $service.service_tags | toStringList ]]
        [[- if $service.check_enabled ]]
        check {
          type     = "http"
          path     = [[ $service.check_path | quote ]]
          interval = [[ $service.check_interval | quote ]]
          timeout  = [[ $service.check_timeout | quote ]]
        }
        [[- end ]]
      }
      [[- end ]]
      [[- end ]]
      [[- end ]]

      [[ template "traefik_config" . ]]
    }
  }
}

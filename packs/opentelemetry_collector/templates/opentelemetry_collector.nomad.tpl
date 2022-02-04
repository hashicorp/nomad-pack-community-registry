[[- $vars := .opentelemetry_collector -]]
job [[ template "full_job_name" . ]] {
  [[ template "region" . ]]

  datacenters = [[ $vars.datacenters | toPrettyJson ]]
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

  group "opentelemetry_collector" {
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

    task "opentelemetry_collector" {
      driver = "docker"

      config {
        image = "[[ $vars.task_config.image ]]:[[ $vars.task_config.version ]]"

        [[- if $vars.privileged_mode ]]
        pid_mode   = "host"
        privileged = true
        [[- end ]]

        ports = [[ keys $vars.network_config.ports | toPrettyJson ]]

        volumes = [
          "local/otel/config.yaml:/etc/otel/config.yaml",
          [[- if $vars.privileged_mode ]]
          "/:/hostfs:ro,rslave",
          [[- end ]]
        ]
      }

      [[ template "env_vars" . ]]

      template {
        data = <<EOH
[[ $vars.config_yaml ]]
EOH

        change_mode   = "restart"
        destination   = "local/otel/config.yaml"
      }

      [[ template "additional_templates" . ]]

      resources {
        cpu    = [[ $vars.resources.cpu ]]
        memory = [[ $vars.resources.memory ]]
      }

      [[- if $vars.task_services ]]
      [[- range $idx, $service := $vars.task_services ]]
      service {
        name = [[ $service.service_name | quote ]]
        port = [[ $service.service_port_label | quote ]]
        tags = [[ $service.service_tags | toPrettyJson ]]
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
    }
  }
}

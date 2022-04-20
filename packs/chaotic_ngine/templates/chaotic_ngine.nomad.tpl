job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .chaotic_ngine.datacenters | toPrettyJson ]]
  namespace = [[ .chaotic_ngine.namespace | quote ]]

  [[ if .chaotic_ngine.constraints ]][[ range $idx, $constraint := .chaotic_ngine.constraints ]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    value = [[ $constraint.value | quote ]]
    [[- if ne $constraint.operator "" ]]
    operator = [[ $constraint.operator | quote ]]
    [[- end ]]
  }
  [[- end ]][[- end ]]

  type = "batch"
  priority = [[ .chaotic_ngine.priority ]]

  periodic {
    cron = [[ .chaotic_ngine.cron | quote ]]
    prohibit_overlap = true
  }

  group "chaotic_ngine" {
    count = 1
    task "chaotic_ngine" {
      driver = "docker"

      env = {
        TZ = [[ .chaotic_ngine.timezone | quote ]]

        [[- if .chaotic_ngine.nomad_addr ]]
        NOMAD_ADDR = [[ .chaotic_ngine.nomad_addr | quote ]]
        [[- end ]]

        [[- if .chaotic_ngine.config_template_url ]]
        CHAOTIC_CONFIG = [[ .chaotic_ngine.config_template_url | quote ]]
        [[ else ]]
        CHAOTIC_CONFIG = "/app/config.yaml"
        [[- end ]]
      }

      config {
        image = "registry.gitlab.com/ngine/docker-images/chaotic:[[ .chaotic_ngine.image_version ]]"
        force_pull = true

        [[- if .chaotic_ngine.config ]]
        volumes = [
          "local/config.yaml:/app/config.yaml:ro",
        ]
        [[- end ]]
      }

      [[- if not .chaotic_ngine.config_template_url ]]
      template {
        change_mode = "noop"
        destination = "local/config.yaml"
        data = [[ .chaotic_ngine.config | quote ]]
      }
      [[- end ]]
    }
  }
}

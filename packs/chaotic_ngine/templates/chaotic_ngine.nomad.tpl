job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .my.datacenters | toStringList ]]
  namespace = [[ .my.namespace | quote ]]

  [[ if .my.constraints ]][[ range $idx, $constraint := .my.constraints ]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    value = [[ $constraint.value | quote ]]
    [[- if ne $constraint.operator "" ]]
    operator = [[ $constraint.operator | quote ]]
    [[- end ]]
  }
  [[- end ]][[- end ]]

  type = "batch"
  priority = [[ .my.priority ]]

  periodic {
    cron = [[ .my.cron | quote ]]
    prohibit_overlap = true
  }

  group "chaotic_ngine" {
    count = 1
    task "chaotic_ngine" {
      driver = "docker"

      env = {
        TZ = [[ .my.timezone | quote ]]

        [[- if .my.nomad_addr ]]
        NOMAD_ADDR = [[ .my.nomad_addr | quote ]]
        [[- end ]]

        [[- if .my.config_template_url ]]
        CHAOTIC_CONFIG = [[ .my.config_template_url | quote ]]
        [[ else ]]
        CHAOTIC_CONFIG = "/app/config.yaml"
        [[- end ]]
      }

      config {
        image = "registry.gitlab.com/ngine/docker-images/chaotic:[[ .my.image_version ]]"
        force_pull = true

        [[- if .my.config ]]
        volumes = [
          "local/config.yaml:/app/config.yaml:ro",
        ]
        [[- end ]]
      }

      [[- if not .my.config_template_url ]]
      template {
        change_mode = "noop"
        destination = "local/config.yaml"
        data = [[ .my.config | quote ]]
      }
      [[- end ]]
    }
  }
}

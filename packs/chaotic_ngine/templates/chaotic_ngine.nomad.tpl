job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ var "datacenters" . | toStringList ]]
  namespace = [[ var "namespace" . | quote ]]

  [[ if var "constraints" . ]][[ range $idx, $constraint := var "constraints" . ]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    value = [[ $constraint.value | quote ]]
    [[- if ne $constraint.operator "" ]]
    operator = [[ $constraint.operator | quote ]]
    [[- end ]]
  }
  [[- end ]][[- end ]]

  type = "batch"
  priority = [[ var "priority" . ]]

  periodic {
    cron = [[ var "cron" . | quote ]]
    prohibit_overlap = true
  }

  group "chaotic_ngine" {
    count = 1
    task "chaotic_ngine" {
      driver = "docker"

      env = {
        TZ = [[ var "timezone" . | quote ]]

        [[- if var "nomad_addr" . ]]
        NOMAD_ADDR = [[ var "nomad_addr" . | quote ]]
        [[- end ]]

        [[- if var "config_template_url" . ]]
        CHAOTIC_CONFIG = [[ var "config_template_url" . | quote ]]
        [[ else ]]
        CHAOTIC_CONFIG = "/app/config.yaml"
        [[- end ]]
      }

      config {
        image = "registry.gitlab.com/ngine/docker-images/chaotic:[[ var "image_version" . ]]"
        force_pull = true

        [[- if var "config" . ]]
        volumes = [
          "local/config.yaml:/app/config.yaml:ro",
        ]
        [[- end ]]
      }

      [[- if not (var "config_template_url" .) ]]
      template {
        change_mode = "noop"
        destination = "local/config.yaml"
        data = [[ var "config" . | quote ]]
      }
      [[- end ]]
    }
  }
}

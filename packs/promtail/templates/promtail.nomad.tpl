job [[ template "job_name" . ]] {

  [[ template "region" . ]]
  datacenters = [[ .promtail.datacenters | toPrettyJson ]]
  namespace   = [[ .promtail.namespace | quote ]]
  type        = "system"
  
  [[ template "constraints" .promtail.constraints ]]

  group "promtail" {
    network {
      mode = [[ .promtail.promtail_group_network.mode | quote ]]
      [[- range $label, $to := .promtail.promtail_group_network.ports ]]
      port [[ $label | quote ]] {
        to = [[ $to ]]
      }
      [[- end ]]
    }

    [[- if .promtail.promtail_task_services ]]
    [[ template "service" .promtail.promtail_group_services ]]
    [[- end ]]

    task "promtail" {
      driver = "docker"
      
      template {
        destination = "local/promtail-config.yaml"
        data = <<-EOT
[[ template "promtail_config" . ]]
        EOT
      }

      config {
        image = "grafana/promtail:[[ .promtail.version_tag ]]"
        privileged = true
        args = [[ .promtail.container_args | toPrettyJson ]]

        mount {
          type = "bind"
          target = "/etc/promtail/promtail-config.yaml"
          source = "local/promtail-config.yaml"
          readonly = false
          bind_options { propagation = "rshared" }
        }

        [[- if (eq .promtail.config_file "") ]]
        [[ template "mounts" .promtail.default_mounts ]]
        [[- end ]]

        [[- if gt (len .promtail.extra_mounts) 0 ]]
        [[ template "mounts" .promtail.extra_mounts ]]
        [[- end ]]

      }
      resources {
        cpu    = [[ .promtail.resources.cpu ]]
        memory = [[ .promtail.resources.memory ]]
      }
    }
  }
}

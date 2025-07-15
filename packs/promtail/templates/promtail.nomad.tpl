job [[ template "job_name" . ]] {

  [[ template "region" . ]]
  datacenters = [[ var "datacenters" . | toStringList ]]
  node_pool   = [[ var "node_pool" . | quote ]]
  namespace   = [[ var "namespace" . | quote ]]
  type        = "system"
  
  [[ template "constraints" var "constraints" . ]]

  group "promtail" {
    network {
      mode = [[ var "promtail_group_network.mode" . | quote ]]
      [[- range $label, $to := var "promtail_group_network.ports" . ]]
      port [[ $label | quote ]] {
        to = [[ $to ]]
      }
      [[- end ]]
    }

    [[- if var "promtail_task_services" . ]]
    [[ template "service" var "promtail_group_services" . ]]
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
        image = "grafana/promtail:[[ var "version_tag" . ]]"
        privileged = true
        args = [[ var "container_args" . | toPrettyJson ]]

        mount {
          type = "bind"
          target = "/etc/promtail/promtail-config.yaml"
          source = "local/promtail-config.yaml"
          readonly = false
          bind_options { propagation = "rshared" }
        }

        [[- if (eq (var "config_file" .) "") ]]
        [[ template "mounts" var "default_mounts" . ]]
        [[- end ]]

        [[- if gt (len (var "extra_mounts" .)) 0 ]]
        [[ template "mounts" var "extra_mounts" . ]]
        [[- end ]]

      }
      resources {
        cpu    = [[ var "resources.cpu" . ]]
        memory = [[ var "resources.memory" . ]]
      }
    }
  }
}

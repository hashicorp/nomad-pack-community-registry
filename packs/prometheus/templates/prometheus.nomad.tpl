job [[ template "full_job_name" . ]] {

  region      = [[ var "region" . | quote ]]
  datacenters = [[ var "datacenters" . | toStringList ]]
  node_pool   = [[ var "node_pool" . | quote ]]
  namespace   = [[ var "namespace" . | quote ]]
  [[ if var "constraints" . ]][[ range $idx, $constraint := var "constraints" . ]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    value     = [[ $constraint.value | quote ]]
    [[- if ne $constraint.operator "" ]]
    operator  = [[ $constraint.operator | quote ]]
    [[- end ]]
  }
  [[- end ]][[- end ]]

  group "prometheus" {

    network {
      mode = [[ var "prometheus_group_network.mode" . | quote ]]
      [[- range $label, $to := var "prometheus_group_network.ports" . ]]
      port [[ $label | quote ]] {
        to = [[ $to ]]
      }
      [[- end ]]
    }

    task "prometheus" {
      driver = "docker"

      config {
        image = "prom/prometheus:v[[ var "prometheus_task.version" . ]]"
        args = [[ var "prometheus_task.cli_args" . | toPrettyJson ]]
        volumes = [
          "local/config:/etc/prometheus/config",
        ]
      }

[[- if ne (var "prometheus_task_app_prometheus_yaml" .) "" ]]
      template {
        data = <<EOH
[[ var "prometheus_task_app_prometheus_yaml" . ]]
EOH

        change_mode   = "signal"
        change_signal = "SIGHUP"
        destination   = "local/config/prometheus.yml"
      }
[[- end ]]

[[- if ne (var "prometheus_task_app_rules_yaml" .) "" ]]
      template {
        data = <<EOH
[[ var "prometheus_task_app_rules_yaml" . ]]
EOH

        change_mode   = "signal"
        change_signal = "SIGHUP"
        destination   = "local/config/rules.yml"
      }
[[- end ]]

      resources {
        cpu    = [[ var "prometheus_task_resources.cpu" . ]]
        memory = [[ var "prometheus_task_resources.memory" . ]]
      }

      [[- if var "prometheus_task_services" . ]]
      [[- range $idx, $service := var "prometheus_task_services" . ]]
      service {
        name = [[ $service.service_name | quote ]]
        port = [[ $service.service_port_label | quote ]]
        tags = [[ $service.service_tags | toStringList ]]

        check {
          type     = "http"
          path     = [[ $service.check_path | quote ]]
          interval = [[ $service.check_interval | quote ]]
          timeout  = [[ $service.check_timeout | quote ]]
        }
      }
      [[- end ]]
      [[- end ]]
    }
  }
}

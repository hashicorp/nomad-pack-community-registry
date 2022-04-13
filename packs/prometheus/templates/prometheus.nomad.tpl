job [[ template "full_job_name" . ]] {

  region      = [[ .prometheus.region | quote ]]
  datacenters = [[ .prometheus.datacenters | toStringList ]]
  namespace   = [[ .prometheus.namespace | quote ]]
  [[ if .prometheus.constraints ]][[ range $idx, $constraint := .prometheus.constraints ]]
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
      mode = [[ .prometheus.prometheus_group_network.mode | quote ]]
      [[- range $label, $to := .prometheus.prometheus_group_network.ports ]]
      port [[ $label | quote ]] {
        to = [[ $to ]]
      }
      [[- end ]]
    }

    task "prometheus" {
      driver = "docker"

      config {
        image = "prom/prometheus:v[[ .prometheus.prometheus_task.version ]]"
        args = [[ .prometheus.prometheus_task.cli_args | toPrettyJson ]]
        volumes = [
          "local/config:/etc/prometheus/config",
        ]
      }

[[- if ne .prometheus.prometheus_task_app_prometheus_yaml "" ]]
      template {
        data = <<EOH
[[ .prometheus.prometheus_task_app_prometheus_yaml ]]
EOH

        change_mode   = "signal"
        change_signal = "SIGHUP"
        destination   = "local/config/prometheus.yml"
      }
[[- end ]]

[[- if ne .prometheus.prometheus_task_app_rules_yaml "" ]]
      template {
        data = <<EOH
[[ .prometheus.prometheus_task_app_rules_yaml ]]
EOH

        change_mode   = "signal"
        change_signal = "SIGHUP"
        destination   = "local/config/rules.yml"
      }
[[- end ]]

      resources {
        cpu    = [[ .prometheus.prometheus_task_resources.cpu ]]
        memory = [[ .prometheus.prometheus_task_resources.memory ]]
      }

      [[- if .prometheus.prometheus_task_services ]]
      [[- range $idx, $service := .prometheus.prometheus_task_services ]]
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

job [[ template "job_name" . ]] {

  region      = [[ .prometheus_consul_exporter.region | quote]]
  datacenters = [[ .prometheus_consul_exporter.datacenters | toPrettyJson ]]
  namespace   = [[ .prometheus_consul_exporter.namespace | quote]]
  type        = "service"
  [[ if .prometheus_consul_exporter.constraints ]][[ range $idx, $constraint := .prometheus_consul_exporter.constraints ]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    value     = [[ $constraint.value | quote ]]
    [[- if ne $constraint.operator "" ]]
    operator  = [[ $constraint.operator | quote ]]
    [[- end ]]
  }
  [[- end ]][[- end ]]

  group "prometheus_consul_exporter" {

    network {
      mode = [[ .prometheus_consul_exporter.consul_exporter_group_network.mode | quote ]]
      [[- range $label, $to := .prometheus_consul_exporter.consul_exporter_group_network.ports ]]
      port [[ $label | quote ]] {
        to = [[ $to ]]
      }
      [[- end ]]
    }

    task "prometheus_consul_exporter" {
      driver = "docker"

      config {
        image = "prom/consul-exporter:[[ .prometheus_consul_exporter.consul_exporter_task_config.version ]]"
        args  = [[ .prometheus_consul_exporter.consul_exporter_task_config.args | toPrettyJson ]]
      }

      resources {
        cpu    = [[ .prometheus_consul_exporter.consul_exporter_task_resources.cpu ]]
        memory = [[ .prometheus_consul_exporter.consul_exporter_task_resources.memory ]]
      }
      [[ if .prometheus_consul_exporter.consul_exporter_task_services ]][[ range $idx, $service := .prometheus_consul_exporter.consul_exporter_task_services ]]
      service {
        name = [[ $service.service_name | quote ]]
        port = [[ $service.service_port_label | quote ]]
        tags = [[ $service.service_tags | toPrettyJson ]]

        [[- if $service.check_enabled ]]
        check {
          type     = [[ $service.check_type | quote ]]
          path     = [[ $service.check_path | quote ]]
          interval = [[ $service.check_interval | quote ]]
          timeout  = [[ $service.check_timeout | quote ]]
        }
        [[- end ]]
      }
      [[- end ]][[ end ]]
    }
  }
}

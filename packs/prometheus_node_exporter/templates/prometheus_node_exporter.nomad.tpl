job [[ template "job_name" . ]] {

  region      = [[ .prometheus_node_exporter.region | quote]]
  datacenters = [[ .prometheus_node_exporter.datacenters | toPrettyJson ]]
  type        = "system"
  [[ if .prometheus_node_exporter.constraints ]][[ range $idx, $constraint := .prometheus_node_exporter.constraints ]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    value     = [[ $constraint.value | quote ]]
    [[- if ne $constraint.operator "" ]]
    operator  = [[ $constraint.operator | quote ]]
    [[- end ]]
  }
  [[- end ]][[- end ]]

  group "prometheus_node_exporter" {

    network {
      mode = [[ .prometheus_node_exporter.node_exporter_group_network.mode | quote ]]
      [[- range $label, $to := .prometheus_node_exporter.node_exporter_group_network.ports ]]
      port [[ $label | quote ]] {
        to = [[ $to ]]
      }
      [[- end ]]
    }

    task "prometheus_node_exporter" {
      driver = "docker"

      config {
        image    = "quay.io/prometheus/node-exporter:[[ .prometheus_node_exporter.node_exporter_task_config.version ]]"
        args     = ["--path.rootfs=/host"]
        pid_mode = "host"

        volumes = [
          "/:/host:ro,rslave",
        ]
      }

      resources {
        cpu    = [[ .prometheus_node_exporter.node_exporter_task_resources.cpu ]]
        memory = [[ .prometheus_node_exporter.node_exporter_task_resources.memory ]]
      }
      [[ if .prometheus_node_exporter.node_exporter_task_services ]][[ range $idx, $service := .prometheus_node_exporter.node_exporter_task_services ]]
      service {
        name = [[ $service.service_name | quote ]]
        port = [[ $service.service_port_label | quote ]]
        tags = [[ $service.service_tags | toPrettyJson ]]

        [[- if $service.check_enabled ]]
        check {
          type     = [[ $service.check_type | quote ]]
          interval = [[ $service.check_interval | quote ]]
          timeout  = [[ $service.check_timeout | quote ]]
        }
        [[- end ]]
      }
      [[- end ]][[ end ]]
    }
  }
}

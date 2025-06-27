job [[ template "job_name" . ]] {

  region      = [[ var "region" . | quote]]
  datacenters = [[ var "datacenters" . | toStringList ]]
  type        = "system"
  [[ if var "constraints" . ]][[ range $idx, $constraint := var "constraints" . ]]
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
      mode = [[ var "node_exporter_group_network.mode" . | quote ]]
      [[- range $label, $to := var "node_exporter_group_network.ports" . ]]
      port [[ $label | quote ]] {
        to = [[ $to ]]
      }
      [[- end ]]
    }

    task "prometheus_node_exporter" {
      driver = "docker"

      config {
        image    = "quay.io/prometheus/node-exporter:[[ var "node_exporter_task_config.version" . ]]"
        args     = ["--path.rootfs=/host"]
        pid_mode = "host"

        volumes = [
          "/:/host:ro,rslave",
        ]
      }

      resources {
        cpu    = [[ var "node_exporter_task_resources.cpu" . ]]
        memory = [[ var "node_exporter_task_resources.memory" . ]]
      }
      [[ if var "node_exporter_task_services" . ]][[ range $idx, $service := var "node_exporter_task_services" . ]]
      service {
        name = [[ $service.service_name | quote ]]
        port = [[ $service.service_port_label | quote ]]
        tags = [[ $service.service_tags | toStringList ]]

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

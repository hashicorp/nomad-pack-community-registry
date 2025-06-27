job [[ template "full_job_name" . ]] {
  region      = [[ var "region" . | quote ]]
  datacenters = [[ var "datacenters" . | toStringList ]]
  namespace   = [[ var "namespace" . | quote ]]

  type = [[ var "job_type" . | quote ]]

  [[ if var "constraints" . ]][[ range $idx, $constraint := var "constraints" . ]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    value     = [[ $constraint.value | quote ]]
    [[- if ne $constraint.operator "" ]]
    operator  = [[ $constraint.operator | quote ]]
    [[- end ]]
  }
  [[- end ]][[- end ]]

  group "prometheus_snmp_exporter" {
    [[- if eq (var "job_type" .) "service" ]]
    count = [[ var "instance_count" . ]]
    [[- end ]]
    network {
      mode = [[ var "snmp_exporter_group_network.mode" . | quote ]]
      [[- range $label, $to := var "snmp_exporter_group_network.ports" . ]]
      port [[ $label | quote ]] {
        to = [[ $to ]]
      }
      [[- end ]]
    }

    task "prometheus_snmp_exporter" {
      driver = "docker"
      config {
        image = "[[ var "snmp_exporter_task_config.image" . ]]:[[ var "snmp_exporter_task_config.version" . ]]"
      }

      resources {
        cpu    = [[ var "snmp_exporter_task_resources.cpu" . ]]
        memory = [[ var "snmp_exporter_task_resources.memory" . ]]
      }

      [[- if var "snmp_exporter_task_services" . ]]
      [[- range $idx, $service := var "snmp_exporter_task_services" . ]]
      service {
        name = [[ $service.service_name | quote ]]
        port = [[ $service.service_port_label | quote ]]
        tags = [[ $service.service_tags | toStringList ]]
        [[- if $service.check_enabled ]]
        check {
          type     = "http"
          path     = [[ $service.check_path | quote ]]
          interval = [[ $service.check_interval | quote ]]
          timeout  = [[ $service.check_timeout | quote ]]
        }
        [[- end ]]
      }
      [[- end ]]
      [[- end ]]
    }
  }
}

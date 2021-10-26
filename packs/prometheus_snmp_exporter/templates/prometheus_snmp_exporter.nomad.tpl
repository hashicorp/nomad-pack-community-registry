[[- $vars := .prometheus_snmp_exporter -]]
job [[ template "full_job_name" . ]] {
  region      = [[ $vars.region | quote ]]
  datacenters = [[ $vars.datacenters | toPrettyJson ]]
  namespace   = [[ $vars.namespace | quote ]]

  type = [[ $vars.job_type | quote ]]

  [[ if $vars.constraints ]][[ range $idx, $constraint := $vars.constraints ]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    value     = [[ $constraint.value | quote ]]
    [[- if ne $constraint.operator "" ]]
    operator  = [[ $constraint.operator | quote ]]
    [[- end ]]
  }
  [[- end ]][[- end ]]

  group "prometheus_snmp_exporter" {
    [[- if eq $vars.job_type "service" ]]
    count = [[ $vars.instance_count ]]
    [[- end ]]
    network {
      mode = [[ $vars.snmp_exporter_group_network.mode | quote ]]
      [[- range $label, $to := $vars.snmp_exporter_group_network.ports ]]
      port [[ $label | quote ]] {
        to = [[ $to ]]
      }
      [[- end ]]
    }

    task "prometheus_snmp_exporter" {
      driver = "docker"
      config {
        image = "[[ $vars.snmp_exporter_task_config.image ]]:[[ $vars.snmp_exporter_task_config.version ]]"
      }

      resources {
        cpu    = [[ $vars.snmp_exporter_task_resources.cpu ]]
        memory = [[ $vars.snmp_exporter_task_resources.memory ]]
      }

      [[- if $vars.snmp_exporter_task_services ]]
      [[- range $idx, $service := $vars.snmp_exporter_task_services ]]
      service {
        name = [[ $service.service_name | quote ]]
        port = [[ $service.service_port_label | quote ]]
        tags = [[ $service.service_tags | toPrettyJson ]]
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

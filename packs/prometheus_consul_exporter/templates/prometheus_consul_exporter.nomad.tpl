job [[ template "job_name" . ]] {

  region      = [[ var "region" . | quote]]
  datacenters = [[ var "datacenters" . | toStringList ]]
  node_pool   = [[ var "node_pool" . | quote ]]
  namespace   = [[ var "namespace" . | quote]]
  type        = "service"
  [[ if var "constraints" . ]][[ range $idx, $constraint := var "constraints" . ]]
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
      mode = [[ var "consul_exporter_group_network.mode" . | quote ]]
      [[- range $label, $to := var "consul_exporter_group_network.ports" . ]]
      port [[ $label | quote ]] {
        to = [[ $to ]]
      }
      [[- end ]]
    }

    task "prometheus_consul_exporter" {
      driver = "docker"

      config {
        image = "prom/consul-exporter:[[ var "consul_exporter_task_config.version" . ]]"
        args  = [[ var "consul_exporter_task_config.args" . | toPrettyJson ]]
      }

      resources {
        cpu    = [[ var "consul_exporter_task_resources.cpu" . ]]
        memory = [[ var "consul_exporter_task_resources.memory" . ]]
      }
      [[ if var "consul_exporter_task_services" . ]][[ range $idx, $service := var "consul_exporter_task_services" . ]]
      service {
        name = [[ $service.service_name | quote ]]
        port = [[ $service.service_port_label | quote ]]
        tags = [[ $service.service_tags | toStringList ]]

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

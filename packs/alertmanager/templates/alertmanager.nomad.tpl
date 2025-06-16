job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ var "datacenters" . | toStringList ]]

  [[ if var "constraints" . ]][[ range $idx, $constraint := var "constraints" . ]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    value     = [[ $constraint.value | quote ]]
    [[- if ne $constraint.operator "" ]]
    operator  = [[ $constraint.operator | quote ]]
    [[- end ]]
  }
  [[- end ]][[- end ]]

  group "alertmanager" {
    count = [[ var "count" . ]]

    network {
      mode = [[ var "alertmanager_group_network.mode" . | quote ]]
      [[- range $label, $to := var "alertmanager_group_network.ports" . ]]
      port [[ $label | quote ]] {
        to = [[ $to ]]
      }
      [[- end ]]
    }

    [[- if var "alertmanager_task_services" . ]]
    [[- range $idx, $service := var "alertmanager_task_services" . ]]
    service {
      name = [[ $service.service_name | quote ]]
      port = [[ $service.service_port_label | quote ]]
      tags = [[ $service.service_tags | toStringList ]]

      [[ if $service.connect_enabled ]]
      connect {
        sidecar_service {}
      }
      [[ end ]]

      check {
        type     = "http"
        path     = [[ $service.check_path | quote ]]
        interval = [[ $service.check_interval | quote ]]
        timeout  = [[ $service.check_timeout | quote ]]
      }
    }
    [[- end ]]
    [[- end ]]

    [[ if var "register_consul_service" . ]]
    service {
      name = "[[ var "consul_service_name" . ]]"
      tags = [[ var "consul_service_tags" . | toStringList ]]
      port = "[[ var "http_port" . ]]"
      [[ if var "register_consul_service" . ]]
      connect {
        sidecar_service {}
      }
      [[ end ]]
    }
    [[ end ]]

    task "alertmanager" {
      driver = "docker"

      config {
        image = "prom/alertmanager:[[ var "version_tag" . ]]"
        args = [[ var "container_args" . | toPrettyJson ]]
        [[- if ne (var "alertmanager_yaml" .) "" ]]
        volumes = [
          "local/config:/etc/alertmanager/config",
        ]
        [[- end ]]
      }

      resources {
        cpu    = [[ var "resources.cpu" . ]]
        memory = [[ var "resources.memory" . ]]
      }

      [[- if ne (var "alertmanager_yaml" .) "" ]]
      template {
        data = <<EOH
[[ var "alertmanager_yaml" . ]]
EOH

        change_mode   = "signal"
        change_signal = "SIGHUP"
        destination   = "local/config/alertmanager.yml"
      }
[[- end ]]
    }
  }
}

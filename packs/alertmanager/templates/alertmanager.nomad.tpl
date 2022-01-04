job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .alertmanager.datacenters | toPrettyJson ]]

  [[ if .alertmanager.constraints ]][[ range $idx, $constraint := .alertmanager.constraints ]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    value     = [[ $constraint.value | quote ]]
    [[- if ne $constraint.operator "" ]]
    operator  = [[ $constraint.operator | quote ]]
    [[- end ]]
  }
  [[- end ]][[- end ]]

  group "alertmanager" {
    count = [[ .alertmanager.count ]]

    network {
      mode = [[ .alertmanager.alertmanager_group_network.mode | quote ]]
      [[- range $label, $to := .alertmanager.alertmanager_group_network.ports ]]
      port [[ $label | quote ]] {
        to = [[ $to ]]
      }
      [[- end ]]
    }

    [[- if .alertmanager.alertmanager_task_services ]]
    [[- range $idx, $service := .alertmanager.alertmanager_task_services ]]
    service {
      name = [[ $service.service_name | quote ]]
      port = [[ $service.service_port_label | quote ]]
      tags = [[ $service.service_tags | toPrettyJson ]]

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

    [[ if .alertmanager.register_consul_service ]]
    service {
      name = "[[ .alertmanager.consul_service_name ]]"
      tags = [[ .alertmanager.consul_service_tags | toPrettyJson ]]
      port = "[[ .alertmanager.http_port ]]"
      [[ if .alertmanager.register_consul_service ]]
      connect {
        sidecar_service {}
      }
      [[ end ]]
    }
    [[ end ]]

    task "alertmanager" {
      driver = "docker"

      config {
        image = "prom/alertmanager:[[ .alertmanager.version_tag ]]"
        args = [[ .alertmanager.container_args | toPrettyJson ]]
        [[- if ne .alertmanager.alertmanager_yaml "" ]]
        volumes = [
          "local/config:/etc/alertmanager/config",
        ]
        [[- end ]]
      }

      resources {
        cpu    = [[ .alertmanager.resources.cpu ]]
        memory = [[ .alertmanager.resources.memory ]]
      }

      [[- if ne .alertmanager.alertmanager_yaml "" ]]
      template {
        data = <<EOH
[[ .alertmanager.alertmanager_yaml ]]
EOH

        change_mode   = "signal"
        change_signal = "SIGHUP"
        destination   = "local/config/alertmanager.yml"
      }
[[- end ]]
    }
  }
}

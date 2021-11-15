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
      mode = "bridge"

      port "http" {
        to = [[ .alertmanager.http_port ]]
      }

      port "cluster" {
        to = [[ .alertmanager.cluster_port ]]
      }
    }

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

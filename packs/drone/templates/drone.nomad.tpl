job [[ template "full_job_name" . ]] {

  region      = [[ .drone.region | quote ]]
  datacenters = [[ .drone.datacenters | toPrettyJson ]]
  namespace   = [[ .drone.namespace | quote ]]

  [[ if .drone.constraints ]][[ range $idx, $constraint := .drone.constraints ]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    value     = [[ $constraint.value | quote ]]
    [[- if ne $constraint.operator "" ]]
    operator  = [[ $constraint.operator | quote ]]
    [[- end ]]
  }
  [[- end ]][[- end ]]

  group "drone" {

    network {
      mode = [[ .drone.group_network.mode | quote ]]
      [[- range $label, $to := .drone.group_network.ports ]]
      port [[ $label | quote ]] {
        to = [[ $to ]]
      }
      [[- end ]]
    }

    task "drone-server" {
      driver = "docker"

      config {
        image = "[[ .drone.drone_server_image ]]:[[ .drone.drone_server_version ]]"
      }

[[- if ne .drone.drone_server_cfg "" ]]
      template {
        data        = <<EOH
[[ .drone.drone_server_cfg ]]
EOH
        destination = "local/env"
        env         = true
      }
[[- end ]]

      resources {
        cpu    = [[ .drone.server_task_resources.cpu ]]
        memory = [[ .drone.server_task_resources.memory ]]
      }
    }

    task "drone-agent" {
      driver = "docker"

      config {
        image = "[[ .drone.drone_agent_image ]]:[[ .drone.drone_agent_version ]]"
      }

[[- if ne .drone.drone_agent_cfg "" ]]
      template {
        data        = <<EOH
[[ .drone.drone_agent_cfg ]]
EOH
        destination = "local/env"
        env         = true
      }
[[- end ]]

      resources {
        cpu    = [[ .drone.agent_task_resources.cpu ]]
        memory = [[ .drone.agent_task_resources.memory ]]
      }

      [[- if .drone.task_services ]]
      [[- range $idx, $service := .drone.task_services ]]
      service {
        name = [[ $service.service_name | quote ]]
        port = [[ $service.service_port_label | quote ]]
        tags = [[ $service.service_tags | toPrettyJson ]]
        check {
          name     = [[ $service.service_name | quote ]]
          port     = [[ $service.service_port_label | quote ]]
          type     = [[ $service.check_type | quote ]]
          interval = [[ $service.check_interval | quote ]]
          timeout  = [[ $service.check_timeout | quote ]]
        }
      }
      [[- end ]]
      [[- end ]]
    }
  }
}

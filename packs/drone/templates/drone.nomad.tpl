job [[ template "full_job_name" . ]] {

  region      = [[ var "region" . | quote ]]
  datacenters = [[ var "datacenters" . | toStringList ]]
  namespace   = [[ var "namespace" . | quote ]]

  [[ if var "constraints" . ]][[ range $idx, $constraint := var "constraints" . ]]
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
      mode = [[ var "group_network.mode" . | quote ]]
      [[- range $label, $to := var "group_network.ports" . ]]
      port [[ $label | quote ]] {
        to = [[ $to ]]
      }
      [[- end ]]
    }

    task "drone-server" {
      driver = "docker"

      config {
        image = "[[ var "drone_server_image" . ]]:[[ var "drone_server_version" . ]]"
      }

[[- if ne (var "drone_server_cfg" .) "" ]]
      template {
        data        = <<EOH
[[ var "drone_server_cfg" . ]]
EOH
        destination = "local/env"
        env         = true
      }
[[- end ]]

      resources {
        cpu    = [[ var "server_task_resources.cpu" . ]]
        memory = [[ var "server_task_resources.memory" . ]]
      }
    }

    task "drone-agent" {
      driver = "docker"

      config {
        image = "[[ var "drone_agent_image" . ]]:[[ var "drone_agent_version" . ]]"
      }

[[- if ne (var "drone_agent_cfg" .) "" ]]
      template {
        data        = <<EOH
[[ var "drone_agent_cfg" . ]]
EOH
        destination = "local/env"
        env         = true
      }
[[- end ]]

      resources {
        cpu    = [[ var "agent_task_resources.cpu" . ]]
        memory = [[ var "agent_task_resources.memory" . ]]
      }

      [[- if var "task_services" . ]]
      [[- range $idx, $service := var "task_services" . ]]
      service {
        name = [[ $service.service_name | quote ]]
        port = [[ $service.service_port_label | quote ]]
        tags = [[ $service.service_tags | toStringList ]]
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

job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ var "datacenters" .  | toStringList ]]
  type = "service"

  group "app" {
    count = [[ var "count" .  ]]

    network {
      [[- range $port := var "ports" .  ]]
      port [[ $port.name | quote ]] {
        to = [[ $port.port ]]
      }
      [[- end ]]
    }

    [[- if var "register_consul_service" .  ]]
    service {
      name = "[[ var "consul_service_name" .  ]]"
      port = "[[ var "consul_service_port" .  ]]"
      tags = [[ var "consul_tags" .  | toStringList ]]

      connect {
        sidecar_service {
          proxy {
            [[- range $upstream := var "upstreams" .  ]]
            upstreams {
              destination_name = [[ $upstream.name | quote ]]
              local_bind_port  = [[ $upstream.port ]]
            }
            [[- end ]]
          }
        }
      }

      [[- if var "has_health_check" .  ]]
      check {
        name     = "alive"
        type     = "http"
        path     = [[ var "health_check.path" . | quote ]]
        interval = [[ var "health_check.interval" . | quote ]]
        timeout  = [[ var "health_check.timeout" . | quote ]]
      }
      [[- end ]]
    }
    [[- end ]]

    restart {
      attempts = [[ var "restart_attempts" .  ]]
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "server" {
      driver = "docker"

      config {
        image = [[ var "image" . | quote]]
        ports = ["http"]
      }

      [[- $env_vars_length := len (var "env_vars" .)  ]]
      [[- if ne $env_vars_length 0 ]]
      env {
        [[- range $var := var "env_vars" .  ]]
        [[ $var.key ]] = [[ $var.value ]]
        [[- end ]]
      }
      [[- end ]]

      resources {
        cpu    = [[ var "resources.cpu" . ]]
        memory = [[ var "resources.memory" . ]]
      }
    }
  }
}

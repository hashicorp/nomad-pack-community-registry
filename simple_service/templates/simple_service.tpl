job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [ [[ range $idx, $dc := .simple_service.datacenters ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]
  type = "service"

  group "app" {
    count = [[ .simple_service.count ]]

    network {
      [[ range $port := .simple_service.ports ]]
      port [[ $port.name | quote ]] {
        to = [[ $port.port ]]
      }
      [[ end ]]
    }

    [[ if .hello_world.register_consul_service ]]
    service {
      name = "[[ .simple_service.consul_service_name ]]"
      port = "[[ .simple_service.consul_service_port ]]"

      connect {
        sidecar_service {
          proxy {
            [[ range $upstream := .simple_service.upstreams ]]
            upstreams {
              destination_name = [[ $upstream.name | quote ]]
              local_bind_port  = [[ $upstream.port ]]
            }
            [[ end ]]
          }
        }
      }

      [[ if .simple_service.has_health_check ]]
      check {
        name     = "alive"
        type     = "http"
        path     = [[ .simple_service.health_check.path | quote ]]
        interval = [[ .simple_service.health_check.interval | quote ]]
        timeout  = [[ .simple_service.health_check.timeout | quote ]]
      }
      [[ end ]]
    }
    [[ end ]]

    restart {
      attempts = [[ .simple_service.restart_attempts ]]
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "server" {
      driver = "docker"

      config {
        image = [[.simple_service.image | quote]]
        ports = ["http"]
      }

      env {
        [[ range $var := .simple_service.env_vars ]]
        [[ $var.key ]] = [[ $var.value ]]
        [[ end ]]
      }

      resources {
        cpu    = [[ .simple_service.resources.cpu ]]
        memory = [[ .simple_service.resources.memory ]]
        [[if .simple_service.resources.memory_max ]]
        memory_max = [[ .simple_service.resources.memory_max ]]
        [[ end ]]
      }
    }
  }
}

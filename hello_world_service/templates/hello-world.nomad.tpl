job "hello_world" {
  datacenters = [ [[ range $idx, $dc := .hello_world_service.datacenters ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]
  type = "service"

  group "app" {
    count = [[ .hello_world_service.app_count ]]

    network {
      port "http" {
        to = 80
      }
    }

    [[ if .hello_world_service.register_consul_service ]]
    service {
      name = "[[ .hello_world_service.consul_service_name ]]"
      tags = [[[ range $idx, $tag := .hello_world_service.consul_service_tags ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]]]
      port = "http"

      check {
        name     = "alive"
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }
    [[ end ]]

    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "server" {
      driver = "docker"
      config {
        image = "[[ .hello_world_service.docker_image ]]"
        ports = ["http"]
      }
    }
  }
}

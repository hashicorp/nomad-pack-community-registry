job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [ [[ range $idx, $dc := .hello_world.datacenters ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]
  type = "service"

  group "app" {
    count = [[ .hello_world.app_count ]]

    network {
      port "http" {
        to = 80
      }
    }

    [[ if .hello_world.register_consul_service ]]
    service {
      name = "[[ .hello_world.consul_service_name ]]"
      tags = [ [[ range $idx, $tag := .hello_world.consul_service_tags ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]
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
        image = "[[ .hello_world.docker_image ]]"
        ports = ["http"]
      }
    }
  }
}

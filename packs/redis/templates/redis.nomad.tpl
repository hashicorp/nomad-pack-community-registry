job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [ [[ range $idx, $dc := .redis.datacenters ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]
  type = "service"

  group "redis" {
    count = [[ .redis.app_count ]]

    [[- if .redis.use_host_volume ]]
    volume "redis" {
      type      = "host"
      source    = [[ .redis.redis_volume | quote ]]
      read_only = false
    }
    [[- end ]]

    network {
      mode = "bridge"
      [[- range $port := .redis.network ]]
      port [[ $port.name | quote ]] {
        to = [[ $port.port ]]
      }
      [[- end ]]
    }

    update {
      min_healthy_time  = [[ .redis.update.min_healthy_time | quote ]]
      healthy_deadline  = [[ .redis.update.healthy_deadline | quote ]]
      progress_deadline = [[ .redis.update.progress_deadline | quote ]]
      auto_revert       = [[ .redis.update.auto_revert ]]
    }

    [[- if .redis.register_consul_service ]]
    service {
      name = [[ .redis.consul_service_name | quote ]]
      port = [[ .redis.consul_service_port | quote ]]
      tags = [ [[ range $idx, $tag := .redis.consul_tags ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]

      connect {
        sidecar_service {}
      }

      [[- if .redis.has_health_check ]]
      check {
        name     = "redis"
        type     = "tcp"
        port     = [[ .redis.health_check.port ]]
        interval = [[ .redis.health_check.interval | quote ]]
        timeout  = [[ .redis.health_check.timeout | quote ]]
      }
      [[- end ]]
    }
    [[- end ]]

    restart {
      attempts = [[ .redis.restart_attempts ]]
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "redis" {
      driver = "docker"
      [[- if .redis.use_host_volume ]]
      volume_mount {
        volume      = "redis"
        destination = "/data"
        read_only   = false
      }
      [[- end ]]
      config {
        image = [[ .redis.image | quote ]]
      }

      resources {
        cpu    = [[ .redis.resources.cpu ]]
        memory = [[ .redis.resources.memory ]]
      }
    }
  }
}

job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .my.datacenters | toStringList ]]
  node_pool = [[ .my.node_pool | quote ]]
  type        = "service"

  group "redis" {
    count = [[ .my.app_count ]]

    [[- if .my.use_host_volume ]]
    volume "redis" {
      type      = "host"
      source    = [[ .my.redis_volume | quote ]]
      read_only = false
    }
    [[- end ]]

    network {
      mode = [[ .my.network.mode | quote ]]
      [[- range $port := .my.network.ports ]]
      port [[ $port.name | quote ]] {
        to = [[ $port.port ]]
      }
      [[- end ]]
    }

    update {
      min_healthy_time  = [[ .my.update.min_healthy_time | quote ]]
      healthy_deadline  = [[ .my.update.healthy_deadline | quote ]]
      progress_deadline = [[ .my.update.progress_deadline | quote ]]
      auto_revert       = [[ .my.update.auto_revert ]]
    }

    [[- if .my.register_consul_service ]]
    service {
      name = [[ .my.consul_service_name | quote ]]
      port = [[ .my.consul_service_port | quote ]]
      tags = [[ .my.consul_tags | toStringList ]]

      connect {
        sidecar_service {}
      }

      [[- if .my.has_health_check ]]
      check {
        name     = "redis"
        type     = "tcp"
        port     = [[ .my.health_check.port ]]
        interval = [[ .my.health_check.interval | quote ]]
        timeout  = [[ .my.health_check.timeout | quote ]]
      }
      [[- end ]]
    }
    [[- end ]]

    restart {
      attempts = [[ .my.restart_attempts ]]
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    task "redis" {
      driver = "docker"
      [[- if .my.use_host_volume ]]
      volume_mount {
        volume      = "redis"
        destination = "/data"
        read_only   = false
      }
      [[- end ]]
      config {
        image = [[ .my.image | quote ]]
      }

      resources {
        cpu    = [[ .my.resources.cpu ]]
        memory = [[ .my.resources.memory ]]
      }
    }
  }
}

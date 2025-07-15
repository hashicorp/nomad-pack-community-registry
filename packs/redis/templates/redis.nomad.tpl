job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ var "datacenters" . | toStringList ]]
  node_pool   = [[ var "node_pool" . | quote ]]

  group "redis" {
    count = [[ var "app_count" . ]]

    [[- if var "use_host_volume" . ]]
    volume "redis" {
      type      = "host"
      source    = [[ var "redis_volume" . | quote ]]
      read_only = false
    }
    [[- end ]]

    network {
      mode = [[ var "network.mode" . | quote ]]
      [[- range $port := var "network.ports" . ]]
      port [[ $port.name | quote ]] {
        to = [[ $port.port ]]
      }
      [[- end ]]
    }

    update {
      min_healthy_time  = [[ var "update.min_healthy_time" . | quote ]]
      healthy_deadline  = [[ var "update.healthy_deadline" . | quote ]]
      progress_deadline = [[ var "update.progress_deadline" . | quote ]]
      auto_revert       = [[ var "update.auto_revert" . ]]
    }

    [[- if var "register_consul_service" . ]]
    service {
      name = [[ var "consul_service_name" . | quote ]]
      port = [[ var "consul_service_port" . | quote ]]
      tags = [[ var "consul_tags" . | toStringList ]]

      connect {
        sidecar_service {}
      }

      [[- if var "has_health_check" . ]]
      check {
        name     = "redis"
        type     = "tcp"
        port     = [[ var "health_check.port" . ]]
        interval = [[ var "health_check.interval" . | quote ]]
        timeout  = [[ var "health_check.timeout" . | quote ]]
      }
      [[- end ]]
    }
    [[- end ]]

    restart {
      attempts = [[ var "restart_attempts" . ]]
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    task "redis" {
      driver = "docker"
      [[- if var "use_host_volume" . ]]
      volume_mount {
        volume      = "redis"
        destination = "/data"
        read_only   = false
      }
      [[- end ]]
      config {
        image = [[ var "image" . | quote ]]
      }

      resources {
        cpu    = [[ var "resources.cpu" . ]]
        memory = [[ var "resources.memory" . ]]
      }
    }
  }
}

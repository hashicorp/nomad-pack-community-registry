job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [ [[ range $idx, $dc := .faasd.datacenters ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]
  type = "service"
  [[ if .faasd.namespace ]]
  namespace   = [[ .faasd.namespace | quote ]]
  [[end]]
  [[ if .faasd.constraints ]][[ range $idx, $constraint := .faasd.constraints ]]
  constraint {
    [[- if ne $constraint.attribute "" ]]
    attribute = [[ $constraint.attribute | quote ]]
    [[- end ]]
    [[- if ne $constraint.value "" ]]
    value     = [[ $constraint.value | quote ]]
    [[- end ]]
    [[- if ne $constraint.operator "" ]]
    operator  = [[ $constraint.operator | quote ]]
    [[- end ]]
  }
  [[- end ]]
  [[- end ]]

  group [[ template "job_name" . ]] {
    count = 1

    network {
      port "faasd_http" {
        static = 8081
        to     = 8081
      }
      port "auth_http" {}
      port "nats_tcp" {}
      port "nats_tcp_1" {
        to = 6222
      }
      port "nats_mon" {}
      port "gateway_http" {
        to = 8080
      }
      port "gateway_mon" {
        to = 8082
      }
    }

    [[ if .faasd.register_auth_consul_service ]]
    service {
      name = "[[ .faasd.consul_service_name ]]"
      [[if ne (len .faasd.consul_service_tags) 0 ]]
      tags = [ [[ range $idx, $tag := .faasd.consul_service_tags ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]
      [[ end ]]
      port = "auth_http"

      check {
        type     = "tcp"
        port     = "auth_http"
        interval = "5s"
        timeout  = "2s"
      }
    }
    [[ end ]]

    [[ if .faasd.register_nats_consul_service ]]
    service {
      name = "[[ .faasd.consul_service_name ]]"
      [[if ne (len .faasd.consul_service_tags) 0 ]]
      tags = [ [[ range $idx, $tag := .faasd.consul_service_tags ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]
      [[ end ]]
      port = "nats_tcp"

      check {
        type     = "tcp"
        port     = "nats_tcp"
        interval = "5s"
        timeout  = "2s"
      }
    }
    [[ end ]]

    [[ if .faasd.register_gateway_consul_service ]]
    service {
      name = "[[ .faasd.consul_service_name ]]"
      [[if ne (len .faasd.consul_service_tags) 0 ]]
      tags = [ [[ range $idx, $tag := .faasd.consul_service_tags ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]
      [[ end ]]
      port = "gateway_http"

      check {
        type     = "tcp"
        port     = "gateway_http"
        interval = "5s"
        timeout  = "2s"
      }
    }
    [[ end ]]

    [[ if .faasd.register_monitoring_consul_service ]]
    service {
      name = "[[ .faasd.consul_service_name ]]"
      [[if ne (len .faasd.consul_service_tags) 0 ]]
      tags = [ [[ range $idx, $tag := .faasd.consul_service_tags ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]
      [[ end ]]
      port = "gateway_monitoring"

      check {
        type     = "http"
        path     = "/metrics"
        port     = "gateway_mon"
        interval = "30s"
        timeout  = "2s"
      }
    }
    [[ end ]]

    [[ if .faasd.register_provider_consul_service ]]
    service {
      name = "[[ .faasd.provider_consul_service_name ]]"
      [[if ne (len .faasd.provider_consul_service_tags) 0 ]]
      tags = [ [[ range $idx, $tag := .faasd.consul_service_tags ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]
      [[ end ]]
      port = "faasd_http"

      check {
        type     = "tcp"
        port     = "faasd_http"
        interval = "5s"
        timeout  = "2s"
      }
    }
    [[ end ]]

    [[ if .faasd.volume_name ]]
    volume "[[.faasd.volume_name]]" {
      type      = "[[.faasd.volume_type]]"
      read_only = false
      source    = "[[.faasd.volume_name]]"
    }
    [[end]]

    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "download-faasd" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      driver = "raw_exec"
      config {
        command = "sh"
        args    = ["-c", "wget -q https://github.com/openfaas/faasd/releases/download/${faasd_version}/faasd && mv faasd /usr/local/bin/faasd && chmod +x /usr/local/bin/faasd"]
      }
    }

    task "faasd_provider" {
      driver = "raw_exec"
      config {
        command = "/usr/local/bin/faasd"
        args    = ["provider"]
      }
      resources {
        cpu    = [[ .faasd.faasd_provider_task_resources.cpu ]]
        memory = [[ .faasd.faasd_provider_task_resources.memory ]]
      }
    }

    task "nats" {
      driver = "docker"
      config {
        image      = "[[.faasd.nats_image_name]]:[[.faasd.nats_image_tag]]"
        ports      = ["nats_tcp", "nats_tcp_1"]
        entrypoint = ["/nats-streaming-server"]
        args = [
          "-p",
          "$${NOMAD_PORT_nats_tcp}",
          "-m",
          "$${NOMAD_PORT_nats_mon}",
          "--store=memory",
          "--cluster_id=faas-cluster",
          "-DV"
        ]
      }
      resources {
        cpu    = [[ .faasd.nats_task_resources.cpu ]]
        memory = [[ .faasd.nats_task_resources.memory ]]
      }
    }

    task "basic-auth-plugin" {
      driver = "docker"

      config {
        image = "ghcr.io/openfaas/basic-auth:${faas_auth_plugin_version}"
        ports = ["auth_http"]

      }

      template {
        data        = "password"
        destination = "secrets/basic-auth-password"
      }

      template {
        data        = "admin"
        destination = "secrets/basic-auth-user"
      }

      env {
        port              = "${NOMAD_PORT_auth_http}"
        secret_mount_path = "/secrets/"
        user_filename     = "basic-auth-user"
        pass_filename     = "basic-auth-password"
      }

      resources {
        cpu    = [[ .faasd.basic_auth_task_resources.cpu ]]
        memory = [[ .faasd.basic_auth_task_resources.memory ]]
      }
    }

    task "gateway" {
      driver = "docker"
      config {
        image = "ghcr.io/openfaas/gateway:${faas_gateway_version}"
        ports = ["gateway_http", "gateway_mon"]
      }
      template {
        data        = "password"
        destination = "secrets/basic-auth-password"
      }
      template {
        data        = "admin"
        destination = "secrets/basic-auth-user"
      }
      env {
        basic_auth             = "true"
        functions_provider_url = [[if .faasd.register_provider_consul_service ]]"http://[[.faasd.provider_consul_service_name]].service.consul:${NOMAD_PORT_faasd_http}/"]][[else]]"http://${NOMAD_ADDR_faasd_http}/"[[end]]
        direct_functions       = "false"
        read_timeout           = "60s"
        write_timeout          = "60s"
        upstream_timeout       = "65s"
        faas_prometheus_host   = "${NOMAD_HOST_IP_gateway_http}"
        faas_nats_address      = "faasd-nats.service.consul"
        faas_nats_port         = "${NOMAD_PORT_nats_tcp}"
        auth_proxy_url         = [[if .faasd.register_basic_auth_consul_service ]]"http://[[.faasd.basic_auth_consul_service_name]].service.consul:$${NOMAD_PORT_auth_http}/validate"[[else]]http://${NOMAD_ADDR_auth_http}/validate[[end]]
        auth_proxy_pass_body   = "false"
        secret_mount_path      = "/secrets"
        scale_from_zero        = "true"
        function_namespace     = "openfaas-fn"
      }
      resources {
        cpu    = [[ .faasd.gateway_task_resources.cpu ]]
        memory = [[ .faasd.gateway_task_resources.memory ]]
      }
    }

    task "queue-worker" {
      driver = "docker"
      config {
        image = "ghcr.io/openfaas/queue-worker:${faas_queue_worker_version}"
      }
      template {
        data        = "password"
        destination = "secrets/basic-auth-password"
      }

      template {
        data        = "admin"
        destination = "secrets/basic-auth-user"
      }
      env {
        faas_nats_address    = [[if .faasd.register_auth_consul_service]]"faasd-nats.service.consul"[[else]]${NOMAD_IP_gateway_http}[[end]]
        faas_nats_port       = "${NOMAD_PORT_nats_tcp}"
        gateway_invoke       = "true"
        faas_gateway_address = [[if .faasd.register_gateway_consul_service]]"faads-gateway.service.consul:${NOMAD_PORT_gateway_http}"[[else]]${NOMAD_ADDR_gateway_http}[[end]]
        ack_wait             = "5m5s"
        max_inflight         = "1"
        write_debug          = "true"
        basic_auth           = "true"
        secret_mount_path    = "/secrets"
      }
      resources {
        cpu    = [[ .faasd.queue_worker_task_resources.cpu ]]
        memory = [[ .faasd.queue_worker_task_resources.memory ]]
      }
    }
  }
}

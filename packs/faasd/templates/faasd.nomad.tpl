job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ var "datacenters" . | toStringList ]]
  type = "service"
  [[- if var "namespace" . ]]
  namespace   = [[ var "namespace" . | quote ]]
  [[- end]]
  [[- if var "constraints" . ]][[ range $idx, $constraint := var "constraints" . ]]
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
      port "faasd_provider_tcp" {
        static = 8081
        to     = 8081
      }
      port "auth_http" {}
      port "nats_tcp_client" {
        to = 4222
      }
      port "nats_http_mon" {
        to = 8222
      }
      port "gateway_http" {
        to = 8080
      }
      port "gateway_mon" {
        to = 8082
      }

      [[- if ne (len (var "dns_servers" .)) 0]]
      dns {
        servers = [[ var "dns_servers" . | toPrettyJson ]]
      }
      [[- end]]
    }

    [[- if var "register_auth_consul_service" . ]]
    service {
      name = "[[ var "auth_consul_service_name" . ]]"
      [[if ne (len var "consul_service_tags" .) 0 ]]
      tags = [[ var "consul_service_tags" . | toStringList ]]
      [[ end ]]
      port = "auth_http"

      check {
        type     = "tcp"
        port     = "auth_http"
        interval = "5s"
        timeout  = "2s"
      }
    }
    [[- end ]]

    [[- if var "register_nats_consul_service" . ]]
    service {
      name = "[[ var "nats_consul_service_name" . ]]"
      [[- if ne (len var "consul_service_tags" .) 0 ]]
      tags = [[ var "consul_service_tags" . | toStringList ]]
      [[- end ]]
      port = "nats_tcp_client"

      check {
        type     = "tcp"
        port     = "nats_tcp_client"
        interval = "5s"
        timeout  = "2s"
      }
    }
    [[- end ]]

    [[- if var "register_nats_consul_service" . ]]
    service {
      name = "faasd-nats-monitoring"
      [[- if ne (len var "nats_consul_service_name" .) 0 ]]
      tags = [[ var "consul_service_tags" . | toStringList ]]
      [[- end ]]
      port = "nats_http_mon"

      check {
        type     = "http"
        path     = "/connz"
        port     = "nats_http_mon"
        interval = "30s"
        timeout  = "2s"
      }
    }
    [[- end]]

    [[- if var "register_gateway_consul_service" . ]]
    service {
      name = "[[ var "gateway_consul_service_name" . ]]"
      [[- if ne (len var "consul_service_tags" .) 0 ]]
      tags = [[ var "consul_service_tags" . | toStringList ]]
      [[- end ]]
      port = "gateway_http"

      check {
        type     = "http"
        path     = "/healthz"
        port     = "gateway_http"
        interval = "5s"
        timeout  = "2s"
      }
    }
    [[- end ]]

    [[- if var "register_provider_consul_service" . ]]
    service {
      name = "[[ var "provider_consul_service_name" . ]]"
      [[if ne (len var "consul_service_tags" .) 0 ]]
      tags = [[ var "consul_service_tags" . | toStringList ]]
      [[ end ]]
      port = "faasd_provider_tcp"

      check {
        type     = "tcp"
        port     = "faasd_provider_tcp"
        interval = "5s"
        timeout  = "2s"
      }
    }
    [[- end ]]

    restart {
      attempts = 3
      delay    = "5s"
      interval = "10m"
      mode     = "delay"
    }

    task "prepare_faasd" {
      lifecycle {
        hook    = "prestart"
      }

      driver = "raw_exec"
      config {
        command = "sh"
        args    = ["-c", "wget -q https://github.com/openfaas/faasd/releases/download/[[ var "faasd_version" . ]]/faasd && mkdir -p /var/lib/faasd && touch /var/lib/faasd/hosts /var/lib/faasd/resolv.conf && mv faasd /usr/local/bin/faasd && chmod +x /usr/local/bin/faasd"]
      }
      env {
        service_timeout = "60s"
      }
    }

    task "faasd_provider" {
      driver = "raw_exec"
      config {
        command = "/usr/local/bin/faasd"
        args    = ["provider"]
      }
      resources {
        cpu    = [[ var "faasd_provider_task_resources.cpu" . ]]
        memory = [[ var "faasd_provider_task_resources.memory" . ]]
      }
    }

    task "nats" {
      driver = "docker"
      config {
        image      = "[[ var "nats_image_name" . ]]:[[ var "nats_image_tag" . ]]"
        ports      = ["nats_tcp_client", "nats_http_mon"]
        entrypoint = ["/nats-streaming-server"]
        args = [
          "-p",
          "$${NOMAD_PORT_nats_tcp_client}",
          "-m",
          "$${NOMAD_PORT_nats_http_mon}",
          "--cluster_id=faas-cluster",
          "-DV"
        ]
      }
      resources {
        cpu    = [[ var "nats_task_resources.cpu" . ]]
        memory = [[ var "nats_task_resources.memory" . ]]
      }
    }

    task "basic_auth_plugin" {
      driver = "docker"

      config {
        image = "[[ var "auth_plugin_image_name" . ]]:[[ var "auth_plugin_image_tag" . ]]"
        ports = ["auth_http"]
      }

      template {
        data        = "[[ var "basic_auth_password" . ]]"
        destination = "secrets/basic-auth-password"
      }

      template {
        data        = "[[ var "basic_auth_user" . ]]"
        destination = "secrets/basic-auth-user"
      }

      env {
        port              = "${NOMAD_PORT_auth_http}"
        secret_mount_path = "/secrets/"
        user_filename     = "basic-auth-user"
        pass_filename     = "basic-auth-password"
      }

      resources {
        cpu    = [[ var "basic_auth_task_resources.cpu" . ]]
        memory = [[ var "basic_auth_task_resources.memory" . ]]
      }
    }

    task "gateway" {
      driver = "docker"
      config {
        image = "[[ var "gateway_image_name" . ]]:[[ var "gateway_image_tag" . ]]"
        ports = ["gateway_http", "gateway_mon"]
      }
      template {
        data        = "[[ var "basic_auth_password" . ]]"
        destination = "secrets/basic-auth-password"
      }
      template {
        data        = "[[ var "basic_auth_user" . ]]"
        destination = "secrets/basic-auth-user"
      }
      env {
        basic_auth             = "true"
        functions_provider_url = [[if var "register_provider_consul_service" . ]]"http://[[ var "provider_consul_service_name" . ]].service.consul:${NOMAD_HOST_PORT_faasd_provider_tcp}/"[[else]]"http://${NOMAD_ADDR_faasd_provider_tcp}/"[[end]]
        direct_functions       = "false"
        read_timeout           = "60s"
        write_timeout          = "60s"
        upstream_timeout       = "60s"
        faas_prometheus_host   = "${NOMAD_HOST_IP_gateway_http}"
        faas_nats_address      = [[if var "register_auth_consul_service" .]]"[[ var "nats_consul_service_name" . ]].service.consul"[[else]]"${NOMAD_HOST_IP_nats_tcp_client}"[[end]]
        faas_nats_port         = "${NOMAD_HOST_PORT_nats_tcp_client}"
        auth_proxy_url         = [[if var "register_basic_auth_consul_service" . ]]"http://[[ var "basic_auth_consul_service_name" . ]].service.consul:$${NOMAD_HOST_PORT_auth_http}/validate"[[else]]"http://${NOMAD_ADDR_auth_http}/validate"[[end]]
        auth_proxy_pass_body   = "false"
        secret_mount_path      = "/secrets"
        scale_from_zero        = "true"
        function_namespace     = "openfaas-fn"
      }
      resources {
        cpu    = [[ var "gateway_task_resources.cpu" . ]]
        memory = [[ var "gateway_task_resources.memory" . ]]
      }
    }

    task "queue_worker" {
      driver = "docker"
      config {
        image = "[[ var "queue_worker_image_name" . ]]:[[ var "queue_worker_image_tag" . ]]"
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
        faas_nats_address    = [[if var "register_auth_consul_service" .]]"[[ var "nats_consul_service_name" . ]].service.consul"[[else]]"${NOMAD_HOST_IP_nats_tcp_client}"[[end]]
        faas_nats_port       = [[if var "register_auth_consul_service" .]]"${NOMAD_HOST_PORT_nats_tcp_client}"[[else]]"${NOMAD_HOST_PORT_nats_tcp_client}"[[end]]
        gateway_invoke       = "true"
        faas_gateway_address = [[if var "register_gateway_consul_service" .]]"[[ var "gateway_consul_service_name" . ]].service.consul:${NOMAD_HOST_PORT_gateway_http}"[[else]]"${NOMAD_HOST_ADDR_gateway_http}"[[end]]
        ack_wait             = "60s"
        max_inflight         = "1"
        write_debug          = "true"
        basic_auth           = "true"
        secret_mount_path    = "/secrets"
      }
      resources {
        cpu    = [[ var "queue_worker_task_resources.cpu" . ]]
        memory = [[ var "queue_worker_task_resources.memory" . ]]
      }
    }
  }
}

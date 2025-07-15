job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ var "datacenters" . | toStringList ]]
  node_pool   = [[ var "node_pool" . | quote ]]

  type        = "service"

  // must have linux for network mode
  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  group "haproxy" {
    count = 1

    network {
      port "http" {
        static = [[ var "http_port" . ]]
      }

      port "haproxy_ui" {
        static = [[ var "ui_port" . ]]
      }
    }

    service {
      name = "haproxy"

      check {
        name     = "alive"
        type     = "tcp"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "haproxy" {
      driver = "docker"

      config {
        image        = "haproxy:[[var "version" .]]"
        network_mode = "host"

        volumes = [
          "local/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg",
        ]
      }

      template {
        data = <<EOF
defaults
   mode http

frontend stats
   bind *:[[ var "ui_port" . ]]
   stats uri /
   stats show-legends
   no log

frontend http_front
   bind *:[[ var "http_port" . ]]
   default_backend http_back

backend http_back
    balance roundrobin
    server-template webapp [[ var "pre_provisioned_slot_count" . ]] _[[ var "consul_service_name" . ]]._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check

resolvers consul
    nameserver consul 127.0.0.1:[[ var "consul_dns_port" . ]]
    accepted_payload_size 8192
    hold valid 5s
EOF

        destination = "local/haproxy.cfg"
      }

      resources {
        cpu    = [[ var "resources.cpu" . ]]
        memory = [[ var "resources.memory" . ]]
      }
    }
  }
}

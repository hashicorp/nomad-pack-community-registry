job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .haproxy.datacenters | toStringList ]]
  node_pool = [[ .haproxy.node_pool | quote ]]

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
        static = [[ .haproxy.http_port ]]
      }

      port "haproxy_ui" {
        static = [[ .haproxy.ui_port ]]
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
        image        = "haproxy:[[.haproxy.version]]"
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
   bind *:[[ .haproxy.ui_port ]]
   stats uri /
   stats show-legends
   no log

frontend http_front
   bind *:[[ .haproxy.http_port ]]
   default_backend http_back

backend http_back
    balance roundrobin
    server-template webapp [[ .haproxy.pre_provisioned_slot_count ]] _[[ .haproxy.consul_service_name ]]._tcp.service.consul resolvers consul resolve-opts allow-dup-ip resolve-prefer ipv4 check

resolvers consul
    nameserver consul 127.0.0.1:[[ .haproxy.consul_dns_port ]]
    accepted_payload_size 8192
    hold valid 5s
EOF

        destination = "local/haproxy.cfg"
      }

      resources {
        cpu    = [[ .haproxy.resources.cpu ]]
        memory = [[ .haproxy.resources.memory ]]
      }
    }
  }
}

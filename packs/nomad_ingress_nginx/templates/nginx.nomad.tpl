job "[[template "job_name" .]]" {
  type = "[[var "job_type" .]]"

  region      = "[[var "region" .]]"
  datacenters = [[var "datacenters" . | toStringList]]
  namespace   = "[[var "namespace" .]]"

  constraint {
    attribute = "${attr.consul.version}"
    operator  = "is_set"
  }

  group "nginx" {
    count = [[var "nginx_count" .]]

    network {
      port "http" {
        static = [[var "http_port" .]]
        [[- if var "http_port_host_network" .]]
        host_network = [[var "http_port_host_network" .]]
        [[- end]]
      }

      [[range var "nginx_extra_ports" .]]
      port "[[.name]]" {
        static = [[.port]]
        [[- if var "host_network" .]]
        host_network = "[[.host_network]]"
        [[- end]]
      }
      [[end]]
    }

    service {
      name = "nomad-ingress-nginx"
      port = "http"

      check {
        type     = "http"
        port     = "http"
        path     = "/health"
        interval = "5s"
        timeout  = "2s"
      }
    }

    task "nginx" {
      driver = "docker"

      config {
        image = "[[var "nginx_image" .]]"

        ports = [
          "http",
          [[- range var "nginx_extra_ports" .]]
          "[[.name]]",
          [[- end]]
        ]

        volumes = [
          "local:/etc/nginx/conf.d",
        ]
      }

      template {
        data = <<EOF
server {
  listen [[var "http_port" .]] default_server;
  server_name _;
  access_log off;

  location /health {
    default_type text/plain;
    return 200;
  }
}
EOF

        destination   = "local/health.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      template {
        data = <<EOF
[[template "ingress_conf" .]]
EOF

        destination   = "local/ingress.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      resources {
        cpu    = [[var "nginx_resources.cpu" .]]
        memory = [[var "nginx_resources.memory" .]]
      }
    }
  }
}

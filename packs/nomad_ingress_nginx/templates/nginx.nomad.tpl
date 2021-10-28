job "[[template "job_name" .]]" {
  type = "[[.nomad_ingress_nginx.job_type]]"

  region      = "[[.nomad_ingress_nginx.region]]"
  datacenters = [[.nomad_ingress_nginx.datacenters | toPrettyJson]]
  namespace   = "[[.nomad_ingress_nginx.namespace]]"

  constraint {
    attribute = "${attr.consul.version}"
    operator  = "is_set"
  }

  group "nginx" {
    count = [[.nomad_ingress_nginx.nginx_count]]

    network {
      port "http" {
        static = [[.nomad_ingress_nginx.http_port]]
        [[- if .nomad_ingress_nginx.http_port_host_network]]
        host_network = [[.nomad_ingress_nginx.http_port_host_network]]
        [[- end]]
      }

      [[range .nomad_ingress_nginx.nginx_extra_ports]]
      port "[[.name]]" {
        static = [[.port]]
        [[- if .host_network]]
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
        image = "[[.nomad_ingress_nginx.nginx_image]]"

        ports = [
          "http",
          [[- range .nomad_ingress_nginx.nginx_extra_ports]]
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
  listen [[.nomad_ingress_nginx.http_port]] default_server;
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
        cpu    = [[.nomad_ingress_nginx.nginx_resources.cpu]]
        memory = [[.nomad_ingress_nginx.nginx_resources.memory]]
      }
    }
  }
}

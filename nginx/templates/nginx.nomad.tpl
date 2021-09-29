job "nginx" {
  region      = {{ .nginx.region | quote}}
  datacenters = [{{ range $idx, $dc := .nginx.datacenters }}{{if $idx}},{{end}}{{ $dc | quote }}{{ end }}]

  group "nginx" {
    count = 1

    network {
      port "http" {
        static = {{ .nginx.http_port }}
      }
    }

    service {
      name = "nginx"
      port = "http"
    }

    task "nginx" {
      driver = "docker"

      config {
        image = "nginx:{{ .nginx.version_tag }}"
        ports = ["http"]

        volumes = [
          "local:/etc/nginx/conf.d",
        ]
      }

      template {
        data = <<EOF
upstream backend {
{{"{{"}} range service {{ .nginx.service_name }} {{"}}"}}
  server {{"{{"}} .Address {{"}}"}}:{{"{{"}} .Port {{"}}"}};
{{"{{"}} else {{"}}"}}server 127.0.0.1:65535; # force a 502
{{"{{"}} end {{"}}"}}
}

server {
   listen {{ .nginx.http_port }};

   location / {
      proxy_pass http://backend;
   }
}
EOF

        destination   = "local/load-balancer.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      resources {
        cpu    = {{ .traefik.resources.cpu }}
        memory = {{ .traefik.resources.memory }}
      }
    }
  }
}

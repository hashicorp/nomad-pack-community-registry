job "traefik" {
  region      = {{ .traefik.region | quote}}
  datacenters = [{{ range $idx, $dc := .traefik.datacenters }}{{if $idx}},{{end}}{{ $dc | quote }}{{ end }}]

  type        = "service"

  group "traefik" {
    count = 1

    network {
      port "http" {
        static = {{ .traefik.http_port }}
      }

      port "api" {
        static = {{ .traefik.api_port }}
      }
    }

    service {
      name = "traefik"

      check {
        name     = "alive"
        type     = "tcp"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "traefik" {
      driver = "docker"

      config {
        image        = "traefik:{{ .traefik.version_tag }}"
        network_mode = "host"

        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml",
        ]
      }

      template {
        data = <<EOF
[entryPoints]
    [entryPoints.http]
    address = ":{{ .traefik.http_port }}"
    [entryPoints.traefik]
    address = ":{{ .traefik.api_port }}"

[api]
    dashboard = true
    insecure  = true

# Enable Consul Catalog configuration backend.
[providers.consulCatalog]
    prefix           = "traefik"
    exposedByDefault = false

    [providers.consulCatalog.endpoint]
      address = "127.0.0.1:{{ .traefik.consul_port }}"
      scheme  = "http"
EOF

        destination = "local/traefik.toml"
      }

      resources {
        cpu    = {{ .traefik.resources.cpu }}
        memory = {{ .traefik.resources.memory }}
      }
    }
  }
}

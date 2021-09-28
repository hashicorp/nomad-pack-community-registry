job "load-balanced-app" {
  region      = {{ .load_balanced_app.region | quote}}
  datacenters = [{{ range $idx, $dc := .load_balanced_app.datacenters }}{{if $idx}},{{end}}{{ $dc | quote }}{{ end }}]
  type = "service"

  group "app" {
    count = {{ .load_balanced_app.app_count }}

    network {
      port "http" {
        to = {{ .load_balanced_app.app_http_port }}
      }
    }

    service {
      name = "{{ .load_balanced_app.service_name }}"
      tags = ["urlprefix-/"]
      port = "http"

      check {
        name     = "alive"
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }

    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "app" {
      driver = "docker"

      config {
        image = "{{ .load_balanced_app.app_image }}"
        ports = ["http"]
      }

      resources {
        cpu    = {{ .load_balanced_app.app_resources.cpu }}
        memory = {{ .load_balanced_app.app_resources.memory }}
      }
    }
  }
}

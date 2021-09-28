job "fabio" {
  region      = {{ .load_balanced_app.region | quote}}
  datacenters = [{{ range $idx, $dc := .load_balanced_app.datacenters }}{{if $idx}},{{end}}{{ $dc | quote }}{{ end }}]

  type = "system"

  group "fabio" {
    network {
      port "lb" {
        static = {{ .load_balanced_app.load_balancer_http_port }}
      }
      port "ui" {
        static = {{ .load_balanced_app.load_balancer_ui_port }}
      }
    }
    task "fabio" {
      driver = "docker"
      config {
        image = "fabiolb/fabio"
        network_mode = "host"
        ports = ["lb","ui"]
      }

      resources {
        cpu    = {{ .load_balanced_app.lb_resources.cpu }}
        memory = {{ .load_balanced_app.lb_resources.memory }}
      }
    }
  }
}

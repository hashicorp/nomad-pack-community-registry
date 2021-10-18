job [[ template "job_name" . ]] {

  [[ template "region" . ]]

  datacenters = [ [[ range $idx, $dc := .promtail.datacenters ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]
  type = "system"
  
  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  group "promtail" {
    count = 1

    network {
      mode = "bridge"
      port "http" {
        to = [[ .promtail.http_port ]]
      }
    }

    service {
      name = [[ .promtail.service_name | quote ]]
      port = "http"
      [[- if not (eq (len .promtail.upstreams) 0) ]] // Render Connect upstreams if defined
      connect {
        sidecar_service {
          proxy {
            [[- range $upstream := .promtail.upstreams ]]
            upstreams {
              destination_name = [[ $upstream.name | quote ]]
              local_bind_port  = [[ $upstream.port ]]
            }
            [[- end ]]
          }
        }
      }
      [[- end ]]
      check {
        name = [[ .promtail.service_check_name | quote ]]
        port = "http"
        type = "http"
        path = "/ready"
        timeout = "2s"
        interval = "10s"
      }
    }

    task "promtail" {
      driver = "docker"
      
      template {
        destination = "local/promtail-config.yaml"
        data = <<EOT
[[ template "promtail_config" . ]]
EOT
      }

      config {
        image = "grafana/promtail:[[ .promtail.version_tag ]]"
        args = [
          "-config.file=/etc/promtail/promtail-config.yaml",
          "-log.level=[[ .promtail.log_level ]]"
        ]

        privileged = [[ if or (.promtail.mount_journal) (.promtail.mount_machine_id) (.promtail.privileged_container) ]]true[[ else ]]false[[ end ]]

        mount {
          type = "bind"
          target = "/etc/promtail/promtail-config.yaml"
          source = "local/promtail-config.yaml"
          readonly = false
          bind_options { propagation = "rshared" }
        }
        [[ if .promtail.mount_journal ]]
        mount {
          type = "bind"
          target = "/var/log/journal"
          source = "/var/log/journal"
          readonly = true
          bind_options { propagation = "rshared" }
        }
        [[ end ]]
        [[ if .promtail.mount_machine_id ]]
        mount {
          type = "bind"
          target = "/etc/machine-id"
          source = "/etc/machine-id"
          readonly = false
          bind_options { propagation = "rshared" }
        }
        [[ end ]]
      }
      resources {
        cpu    = [[ .promtail.resources.cpu ]]
        memory = [[ .promtail.resources.memory ]]
      }
    }
  }
}

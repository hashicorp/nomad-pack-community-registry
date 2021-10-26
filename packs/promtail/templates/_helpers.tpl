// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .promtail.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .promtail.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .promtail.region "") -]]
region = [[ .promtail.region | quote]]
[[- end -]]
[[- end -]]

[[- define "constraints" -]]
[[- range $idx, $constraint := . ]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    [[ if $constraint.operator -]]
    operator  = [[ $constraint.operator | quote ]]
    [[ end -]]
    value     = [[ $constraint.value | quote ]]
  }
[[- end ]]
[[- end -]]

// Use provided config file if defined, else render a default
[[- define "promtail_config" -]]
[[- if (eq .promtail.config_file "") ]]
        server:
          http_listen_port: [[ .promtail.http_port ]]
          log_level: [[ .promtail.log_level ]]

        positions:
          filename: /tmp/positions.yaml

        clients:
          [[ range $idx, $url := .promtail.client_urls ]][[if $idx]]  [[end]][[ $url | printf "- url: %s\n" ]][[ end ]]
        scrape_configs:
        - job_name: journal
          journal:
            max_age: [[ .promtail.journal_max_age ]]
            json: false
            labels:
              job: systemd-journal
          relabel_configs:
          - source_labels:
            - __journal__systemd_unit
            target_label: systemd_unit
          - source_labels:
            - __journal__hostname
            target_label: nodename
          - source_labels:
            - __journal_syslog_identifier
            target_label: syslog_identifier
[[- else ]]
[[ $config := .promtail.config_file ]][[ fileContents $config ]]
[[- end ]]
[[- end -]]

// Generic "service" block template
[[- define "service" -]]
[[- range $idx, $service := . ]]
    service {
      name = [[ $service.service_name | quote ]]
      port = [[ $service.service_port_label | quote ]]
      tags = [[ $service.service_tags | toPrettyJson ]]
      [[- if gt (len $service.upstreams) 0 ]] 
      connect {
        sidecar_service {
          proxy {
            [[- if gt (len $service.upstreams) 0 ]]
            [[- range $upstream := $service.upstreams ]]
            upstreams {
              destination_name = [[ $upstream.name | quote ]]
              local_bind_port  = [[ $upstream.port ]]
            }
            [[- end ]]
            [[- end ]]
          }
        }
      }
      [[- end ]]
      check {
        type     = "http"
        path     = [[ $service.check_path | quote ]]
        interval = [[ $service.check_interval | quote ]]
        timeout  = [[ $service.check_timeout | quote ]]
      }
    }
[[- end ]]
[[- end -]]

[[- define "env" -]]
      env {
        [[- range $idx, $var := . ]]
        [[ $var.name | quote ]] = [[ $var.value | quote ]]
        [[- end ]]
      }
[[- end -]]

[[- define "mounts" -]]
[[- range $idx, $mount := . ]]
        mount {
          type = [[ $mount.type | quote ]]
          target = [[ $mount.target | quote ]]
          source = [[ $mount.source | quote ]]
          readonly = [[ $mount.readonly ]]
          bind_options { 
            [[- range $idx, $opt := $mount.bind_options ]]
            [[ $opt.name ]] = [[ $opt.value | quote ]]
            [[- end ]]
          }
        }
[[- end ]]
[[- end -]]
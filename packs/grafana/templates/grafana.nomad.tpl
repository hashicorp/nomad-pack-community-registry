job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .grafana.datacenters | toStringList ]]

  // must have linux for network mode
  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  group "grafana" {
    count = 1

    network {
      mode = "bridge"

    [[- if .grafana.dns ]]
    dns {
      [[- if .grafana.dns.source ]]
        servers = [[ .grafana.dns.source | toPrettyJson ]]
      [[- end ]]
      [[- if .grafana.dns.searches ]]
        searches = [[ .grafana.dns.searches | toPrettyJson ]]
      [[- end ]]
      [[- if .grafana.dns.options ]]
        options = [[ .grafana.dns.options | toPrettyJson ]]
      [[- end ]]
    }
    [[- end ]]

      port "http" {
        to = [[ .grafana.grafana_http_port ]]
      }
    }

    [[- if .grafana.grafana_volume ]]
    volume "grafana" {
      type = [[ .grafana.grafana_volume.type | quote ]]
      read_only = false
      source = [[ .grafana.grafana_volume.source | quote ]]
    }
    [[- end ]]

    service {
      name = "grafana"
      port = "[[ .grafana.grafana_http_port ]]"
      tags = [[ .grafana.grafana_consul_tags | toStringList ]]

      connect {
        sidecar_service {
          proxy {
            [[ range $upstream := .grafana.upstreams ]]
            upstreams {
              destination_name = [[ $upstream.name | quote ]]
              local_bind_port  = [[ $upstream.port ]]
            }
            [[ end ]]
          }
        }
      }
    }

    task "grafana" {
      driver = "docker"

    [[- if .grafana.grafana_volume ]]
      volume_mount {
        volume      = "grafana"
        destination = "/var/lib/grafana"
        read_only   = false
      }
    [[- end ]]

      config {
        image = "grafana/grafana:[[ .grafana.grafana_version_tag ]]"
        ports = ["http"]
      }

      resources {
        cpu    = [[ .grafana.grafana_resources.cpu ]]
        memory = [[ .grafana.grafana_resources.memory ]]
      }

      env {
        [[- range $var := .grafana.grafana_env_vars ]]
        [[ $var.key ]] = "[[ $var.value ]]"
        [[- end ]]
      }

      [[- if .grafana.grafana_task_artifacts ]]
        [[- range $artifact := .grafana.grafana_task_artifacts ]]

      artifact {
        source      = [[ $artifact.source | quote ]]
        destination = [[ $artifact.destination | quote ]]
        mode = [[ $artifact.mode | quote ]]
        [[- if $artifact.options ]]
        options {
          [[- range $option, $val := $artifact.options ]]
          [[ $option ]] = [[ $val | quote ]]
          [[- end ]]
        }
        [[- end ]]

      }
        [[- end ]]
      [[- end ]]

      [[- if .grafana.grafana_task_config_dashboards ]]
      template {
        data = <<EOF
[[ .grafana.grafana_task_config_dashboards ]]
EOF
        destination = "/local/grafana/provisioning/dashboards/dashboards.yaml"
      }
      [[- end ]]

      [[- if .grafana.grafana_task_config_datasources ]]
      template {
        data = <<EOF
[[ .grafana.grafana_task_config_datasources ]]
EOF
        destination = "/local/grafana/provisioning/datasources/datasources.yaml"
      }
      [[- end ]]

      [[- if .grafana.grafana_task_config_plugins ]]

      template {
        data = <<EOF
[[ .grafana.grafana_task_config_plugins ]]
EOF
        destination = "/local/grafana/provisioning/plugins/plugins.yml"
      }
    [[- end ]]
    }
  }
}

job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ var "datacenters" . | toStringList ]]
  node_pool   = [[ var "node_pool" . | quote ]]

  // must have linux for network mode
  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  group "grafana" {
    count = 1

    network {
      mode = "bridge"

    [[- if var "dns" . ]]
    dns {
      [[- if var "dns.servers" . ]]
        servers = [[ var "dns.servers" . | toPrettyJson ]]
      [[- end ]]
      [[- if var "dns.searches" . ]]
        searches = [[ var "dns.searches" . | toPrettyJson ]]
      [[- end ]]
      [[- if var "dns.options" . ]]
        options = [[ var "dns.options" . | toPrettyJson ]]
      [[- end ]]
    }
    [[- end ]]

      port "http" {
        to = [[ var "grafana_http_port" . ]]
      }
    }

    [[- if var "grafana_vault" . ]]
    vault {
      policies = [[ var "grafana_vault" . | toStringList ]]
      change_mode   = "noop"
    }
    [[- end ]]

    [[- if var "grafana_volume" . ]]
    volume "grafana" {
      type = [[ var "grafana_volume.type" . | quote ]]
      read_only = false
      source = [[ var "grafana_volume.source" . | quote ]]
    }
    [[- end ]]

    service {
      name = "grafana"
      port = [[ var "grafana_http_port" . | quote ]]
      tags = [[ var "grafana_consul_tags" . | toStringList ]]

      connect {
        sidecar_service {
          proxy {
            [[ range $upstream := (var "grafana_upstreams" .) ]]
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

    [[- if var "grafana_volume" . ]]
      volume_mount {
        volume      = "grafana"
        destination = "/var/lib/grafana"
        read_only   = false
      }
    [[- end ]]

      config {
        image = "grafana/grafana:[[ var "grafana_version_tag" . ]]"
        ports = ["http"]
      }

      resources {
        cpu    = [[ var "grafana_resources.cpu" . ]]
        memory = [[ var "grafana_resources.memory" . ]]
      }

      env {
        [[- range $var := (var "grafana_env_vars" .) ]]
        [[ $var.key ]] = [[ $var.value | quote ]]
        [[- end ]]
      }

      [[- if var "grafana_task_artifacts" . ]]
        [[- range $artifact := (var "grafana_task_artifacts" .) ]]

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

      template {
        data = <<EOF
[[ var "grafana_task_config_ini" . ]]
EOF
        destination = "/local/grafana/grafana.ini"
      }

      [[- if var "grafana_task_config_dashboards" . ]]
      template {
        data = <<EOF
[[ var "grafana_task_config_dashboards" . ]]
EOF
        destination = "/local/grafana/provisioning/dashboards/dashboards.yaml"
      }
      [[- end ]]

      [[- if var "grafana_task_config_datasources" . ]]
      template {
        data = <<EOF
[[ var "grafana_task_config_datasources" . ]]
EOF
        destination = "/local/grafana/provisioning/datasources/datasources.yaml"
      }
      [[- end ]]

      [[- if var "grafana_task_config_plugins" . ]]
      template {
        data = <<EOF
[[ var "grafana_task_config_plugins" . ]]
EOF
        destination = "/local/grafana/provisioning/plugins/plugins.yml"
      }
      [[- end ]]
    }
  }
}

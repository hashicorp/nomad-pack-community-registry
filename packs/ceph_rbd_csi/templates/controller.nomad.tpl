job "[[ .my.job_name ]]_controller" {

  [[ template "location" . ]]

  group "controllers" {
    [[ template "constraints" . ]]

    network {
      port "prometheus" {}
    }

    service {
      name = "[[ .my.prometheus_service_name ]]"
      port = "prometheus"
      tags = [[ .my.prometheus_service_tags | toJson ]]
    }

    task "plugin" {
      driver = "docker"

      config {
        image = "[[ .my.plugin_image ]]"

        args = [
          "--drivername=[[ .my.plugin_id ]]",
          "--v=5",
          "--type=rbd",
          "--controllerserver=true",
          "--nodeid=${NODE_ID}",
          "--instanceid=${POD_ID}",
          "--endpoint=${CSI_ENDPOINT}",
          "--metricsport=${NOMAD_PORT_prometheus}",
        ]

        ports      = ["prometheus"]

        # we need to be able to write key material to disk in this location
        mount {
          type     = "bind"
          source   = "secrets"
          target   = "/tmp/csi/keys"
          readonly = false
        }

        mount {
          type     = "bind"
          source   = "ceph-csi-config/config.json"
          target   = "/etc/ceph-csi-config/config.json"
          readonly = false
        }

      }

      template {
        data = <<-EOT
POD_ID=${NOMAD_ALLOC_ID}
NODE_ID=${node.unique.id}
CSI_ENDPOINT=unix://csi/csi.sock
EOT

        destination = "${NOMAD_TASK_DIR}/env"
        env         = true
      }

      # ceph configuration file
      template {

        data = <<EOF
[{
    "clusterID": "[[ .my.ceph_cluster_id ]]",
    "monitors": [
        {{range $index, $service := service "[[ .my.ceph_monitor_service_name ]]"}}{{if gt $index 0}}, {{end}}"{{.Address}}"{{end}}
    ]
}]
EOF

        destination = "ceph-csi-config/config.json"
      }

      csi_plugin {
        id        = "[[ .my.plugin_id ]]"
        type      = "controller"
        mount_dir = "/csi"
      }

      [[- template "resources" . ]]

    }
  }
}

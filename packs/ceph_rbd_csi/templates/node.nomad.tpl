job "[[ .my.job_name ]]_node" {
  # you can run node plugins as service jobs as well, but this ensures
  # that all nodes in the DC have a copy.
  type = "system"
  [[ template "location" . ]]

  group "nodes" {
    [[ template "constraints" . ]]
    constraint {
      attribute = "${attr.driver.docker.privileged.enabled}"
      value     = true
    }

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
          "--nodeserver=true",
          "--nodeid=${NODE_ID}",
          "--instanceid=${POD_ID}",
          "--endpoint=${CSI_ENDPOINT}",
          "--metricsport=${NOMAD_PORT_prometheus}",
        ]

        privileged = true
        ports      = ["prometheus"]
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

      csi_plugin {
        id        = "[[ .my.plugin_id ]]"
        type      = "node"
        mount_dir = "/csi"
      }

      [[- template "resources" . ]]

    }
  }
}

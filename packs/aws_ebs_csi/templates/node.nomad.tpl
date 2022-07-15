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

    task "plugin" {
      driver = "docker"

      config {
        image = "[[ .my.plugin_image ]]"

        args = [
          "node",
          "--endpoint=${CSI_ENDPOINT}",
          "--logtostderr",
          "--v=5",
        ]

        privileged = true
      }

      csi_plugin {
        id        = "[[ .my.plugin_id ]]"
        type      = "node"
        mount_dir = "/csi"
      }

      [[ template "resources" . ]]

    }
  }
}

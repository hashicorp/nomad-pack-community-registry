job "[[ var "job_name" . ]]_controller" {

  [[ template "location" . ]]

  group "controllers" {

    count = [[ var "controller_count" . ]]

    [[ template "constraints" . ]]

    constraint {
      operator = "distinct_hosts"
      value    = "true"
    }

    task "plugin" {
      driver = "docker"

      config {
        image = "[[ var "plugin_image" . ]]"

        args = [
          "controller",
          "--endpoint=${CSI_ENDPOINT}",
          "--logtostderr",
          "--v=5",
        ]
      }

      csi_plugin {
        id        = "[[ var "plugin_id" . ]]"
        type      = "controller"
        mount_dir = "/csi"
      }

      [[ template "resources" . ]]

    }
  }
}

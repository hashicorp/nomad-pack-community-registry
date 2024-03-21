job "[[ .my.job_name ]]_controller" {

  [[ template "location" . ]]

  group "controller" {

    count = [[ .my.controller_count ]]

    [[ template "constraints" . ]]

    constraint {
      operator = "distinct_hosts"
      value    = "true"
    }

    task "plugin" {
      driver = "docker"

      config {
        image = "[[ .my.plugin_image ]]"

        args = [
          "--csi-version=[[ .my.plugin_csi_spec_version ]]",
          "--csi-name=[[ .my.plugin_id ]]",
          "--driver-config-file=${NOMAD_TASK_DIR}/driver-config-file.yaml",
          "--log-level=[[ .my.plugin_log_level ]]",
          "--csi-mode=controller",
          "--server-socket=${CSI_ENDPOINT}",
        ]

        # normally not required for controller plugins, but NFS
        # doesn't have a remote API other than mounting, so this
        # plugin has to be able to mount the NFS volume as a
        # bind-mount in order to create and snapshot volumes.
        privileged = true
        mount {
          type     = "bind"
          source   = "[[ if not .my.nfs_controller_mount_path ]][[fail "nfs_controller_mount_path must be defined"]][[else]][[.my.nfs_controller_mount_path]][[end]]"
          target   = "/storage"
          readonly = false
        }
      }

      [[ template "plugin_config_file" . ]]

      [[ template "resources" . ]]

      csi_plugin {
        id        = "[[ .my.plugin_id ]]"
        type      = "controller"
        mount_dir = "/csi"
      }

    }
  }
}

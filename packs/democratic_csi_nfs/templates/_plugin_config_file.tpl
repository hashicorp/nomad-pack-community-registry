[[- define "plugin_config_file" ]]
      template {
        destination = "${NOMAD_TASK_DIR}/driver-config-file.yaml"

        data = <<EOH
driver: nfs-client
instance_id:
nfs:
  shareHost: [[ .my.nfs_share_host ]]
  shareBasePath: "[[ .my.nfs_share_base_path ]]"
  controllerBasePath: "/storage"
  dirPermissionsMode: "[[ .my.nfs_dir_permissions_mode ]]"
  dirPermissionsUser: [[ .my.nfs_dir_permissions_user ]]
  dirPermissionsGroup: [[ .my.nfs_dir_permissions_group ]]
EOH
      }
[[- end -]]

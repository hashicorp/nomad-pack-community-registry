[[- define "plugin_config_file" ]]
[[- if not (var "nfs_share_host" .) ]][[ fail "nfs_share_host variable must be provided" ]][[ end -]]
[[- if not (var "nfs_share_base_path" .) ]][[ fail "nfs_share_base_path variable must be provided" ]][[ end -]]
      template {
        destination = "${NOMAD_TASK_DIR}/driver-config-file.yaml"

        data = <<EOH
driver: nfs-client
instance_id:
nfs:
  shareHost: [[ var "nfs_share_host" . ]]
  shareBasePath: "[[ var "nfs_share_base_path" . ]]"
  controllerBasePath: "/storage"
  dirPermissionsMode: "[[ var "nfs_dir_permissions_mode" . ]]"
  dirPermissionsUser: [[ var "nfs_dir_permissions_user" . ]]
  dirPermissionsGroup: [[ var "nfs_dir_permissions_group" . ]]
EOH
      }
[[- end -]]

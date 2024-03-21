[[- define "plugin_config_file" ]]
[[- if not ( all .my.nfs_share_host .my.nfs_share_base_path ) -]]
  [[- $u := (list) -]]
  [[/* capture .my because `range` changes . to the current item */]]
  [[- $my := .my -]]
  [[- range list "nfs_share_host" "nfs_share_base_path" -]]
    [[- if not ( index $my . ) ]][[ $u = append $u . ]][[- end -]]
  [[- end ]]
  [[- fail ( join " and " (toStrings $u) | printf "%s must be provided" )  -]] 
[[- end ]]
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

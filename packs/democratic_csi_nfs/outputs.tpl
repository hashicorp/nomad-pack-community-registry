type         = "csi"
id           = "[[ var "volume_id" . ]]"
namespace    = "[[ var "volume_namespace" . ]]"
name         = "[[ var "volume_id" . ]]"
plugin_id    = "[[ var "plugin_id" . ]]"

capability {
  access_mode     = "multi-node-multi-writer"
  attachment_mode = "file-system"
}

capability {
  access_mode     = "single-node-writer"
  attachment_mode = "file-system"
}

capability {
  access_mode     = "single-node-reader-only"
  attachment_mode = "file-system"
}

mount_options {
  mount_flags = ["noatime"]
}

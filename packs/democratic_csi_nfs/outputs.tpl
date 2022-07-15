type         = "csi"
id           = "[[ .my.volume_id ]]"
namespace    = "[[ .my.volume_namespace ]]"
name         = "[[ .my.volume_id ]]"
plugin_id    = "[[ .my.plugin_id ]]"

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

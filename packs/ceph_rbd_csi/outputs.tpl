id        = "[[ .my.volume_id ]]"
name      = "[[ .my.volume_id ]]"
namespace = "[[ .my.volume_namespace ]]"
type      = "csi"
plugin_id = "[[ .my.plugin_id ]]"

capacity_min = "[[ .my.volume_min_capacity ]]"
capacity_max = "[[ .my.volume_max_capacity ]]"

capability {
  access_mode     = "single-node-writer"
  attachment_mode = "file-system"
}

capability {
  access_mode     = "single-node-writer"
  attachment_mode = "block-device"
}

# get this secret from the Ceph allocation:
# /etc/ceph/ceph.client.admin.keyring
secrets {
  userID  = "admin"
  userKey = "AQDsIoxgHqpe...spTbvwZdIzA=="
}

parameters {
  clusterID     = "[[ .my.ceph_cluster_id ]]"
  pool          = "rbd"
  imageFeatures = "layering"
}

id        = "[[ var "volume_id" . ]]"
name      = "[[ var "volume_id" . ]]"
namespace = "[[ var "volume_namespace" . ]]"
type      = "csi"
plugin_id = "[[ var "plugin_id" . ]]"

capacity_min = "[[ var "volume_min_capacity" . ]]"
capacity_max = "[[ var "volume_max_capacity" . ]]"

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
  clusterID     = "[[ var "ceph_cluster_id" . ]]"
  pool          = "rbd"
  imageFeatures = "layering"
}

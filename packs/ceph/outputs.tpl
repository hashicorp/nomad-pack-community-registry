For the Ceph RBD CSI pack, you'll need the ceph_cluster_id and
ceph_monitor_service_name variables. If you haven't set ceph_cluster_id, it
will have been automatically generated and you can find it in the Ceph
allocation file system. Get the "fsid" value here:

    nomad alloc fs :alloc_id ceph/local/ceph/ceph.conf | awk -F' = ' '/fsid/{print $2}'

To create volumes, you'll need the client.admin key value from the Ceph mon
keyring. Read that with:

   nomad alloc fs :alloc_id ceph/local/ceph/ceph.mon.keyring

You'll set this value in the volume secrets block. For example:

secrets {
  userID  = "admin"
  userKey = "AQDsIoxgHqpe..ZdIzA=="
}

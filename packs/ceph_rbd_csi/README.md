# ceph_rbd_csi

This pack deploys two jobs that run the [Ceph
RBD](https://github.com/ceph/ceph-csi) CSI plugin. The node plugin
tasks will be run as a system job, and the controller tasks will be
run as a service job.

## Client Requirements

This pack can only be run on Nomad clients that have enabled volumes
and privileged mode for the Docker task driver. In addition, you must
have the `rbd` kernel module loaded:

```
$ sudo modprobe rbd
$ lsmod | grep rbd
rbd                   106496  0
libceph               327680  1 rbd
```

Without the kernel module loaded, plugins tasks will fail with errors
like: `modprobe: FATAL: Module rbd not found in directory`

## Variables

* `job_name` (string "ceph_rbd_csi") - The prefix to use as the job
  name for the plugins. For exmaple, if `job_name = "ceph_rbd_csi"`,
  the plugin job will be named `ceph_rbd_csi_controller`.
* `datacenters` (list(string) ["dc1"]) - A list of datacenters in the
  region which are eligible for task placement.
* `region` (string "global") - The region where the job should be
  placed.
* `plugin_id` (string "rbd.csi.ceph.com") - The ID to register
  in Nomad for the plugin.
* `plugin_namespace` (string "default") - The namespace for the plugin
  job.
* `plugin_image` (string "quay.io/cephcsi/cephcsi:canary") - The
  container image for the plugin.
* `controller_count` (number 2) - The number of controller instances
  to be deployed (at least 2 recommended).
* `ceph_cluster_id` (string "") - The Ceph cluster ID.
* `ceph_monitor_service_name` (string "ceph-mon") - The Consul service
  name for the Ceph monitoring service.
* `volume_id` (string "myvolume") - ID for the example volume spec to
  output.
* `volume_namespace` (string "default") - Namespace for the example
  volume spec to output.
* `volume_min_capacity` (string "10GiB") - Minimum capacity for the
  example volume spec to output.
* `volume_max_capacity` (string "30GiB") - Maximum capacity for the
  example volume spec to output.

## Volume creation

This pack outputs an example volume specification based on the plugin variables.

#### **`volume.hcl`**

```
id        = "myvolume"
name      = "myvolume"
namespace = "default"
type      = "csi"
plugin_id = "rbd.csi.ceph.com"

capacity_min = "10GiB"
capacity_max = "30GiB"

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
  clusterID     = "129ceb60-ae2e-4313-a9f8-cb6087f97787"
  pool          = "rbd"
  imageFeatures = "layering"
}
```

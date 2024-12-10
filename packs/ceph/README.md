# Ceph

This pack deploys a Ceph container in "demo" mode, where a single
container runs all the required services. This is primarily for
demonstration purposes and to provide a target for the `ceph_rbd_csi`
pack.

**NOTE:** This pack is not suitable for production, and if the
allocation is rescheduled all data written to Ceph will be lost! If
you are interested in submitting an update to make this Ceph pack
production-ready, the Nomad engineering team would enthusiastically
review it!

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

Without the kernel module loaded, plugins that consume Ceph will fail
with errors like: `modprobe: FATAL: Module rbd not found in directory`

## Variables

* `job_name` (string "ceph") - The name to use for the job.
* `datacenters` (list(string) ["dc1"]) - A list of datacenters in the
  region which are eligible for task placement.
* `region` (string "global") - The region where the job should be
  placed.
* `ceph_image` (string "ceph/daemon:latest-octopus") - The container
  image for Ceph.
* `ceph_cluster_id` (string "") - The Ceph cluster ID (will default to
  a random UUID).
* `ceph_demo_uid` (string "demo") - The UID for the Ceph demo.
* `ceph_demo_bucket` (string "example") - The bucket name for the Ceph demo.
* `ceph_monitor_service_name` (string "ceph-mon") - The Consul service
  name for the Ceph monitoring service.
* `ceph_monitor_service_port` (number 3300) - The port for the Ceph
  monitoring service to listen on.
* `ceph_dashboard_service_name` (string "ceph-dashboard") - The Consul
  service name for the Ceph dashboard service.
* `ceph_dashboard_service_port` (number 5000) - The port for the Ceph
  dashboard service to listen on.
* `ceph_config_file` (string "") - The full text of the Ceph demo
  configuration file. A reasonable demo will be provided by default.

#### `constraints` List of Objects

[Nomad job specification
constraints](https://www.nomadproject.io/docs/job-specification/constraint)
allow restricting the set of eligible nodes on which the tasks will
run. This pack automatically configures the following required
constraints:

* The task will run on Linux hosts only
* The task will run on hosts with the Docker driver's
  [`volumes`](https://www.nomadproject.io/docs/drivers/docker#volumes-1)
  enabled and
  [`allow_privileged`](https://www.nomadproject.io/docs/drivers/docker#allow_privileged)
  set to `true`.

You can set additional constraints with the `constraints` variable,
which takes a list of objects with the following fields:

* `attribute` (string) - Specifies the name or reference of the
  attribute to examine for the constraint.
* `operator` (string) - Specifies the comparison operator. The
  ordering is compared lexically.
* `value` (string) - Specifies the value to compare the attribute
  against using the specified operation.

Below is also an example of how to pass `constraints` to the CLI with the `-var` argument.

```bash
nomad-pack run -var 'constraints=[{"attribute":"$${meta.my_custom_value}","operator":">","value":"3"}]' packs/ceph
```

#### `resources` Object

* `cpu` (number 256) - Specifies the CPU required to run this task in
  MHz.
* `memory` (number 600) - Specifies the memory required in MB.

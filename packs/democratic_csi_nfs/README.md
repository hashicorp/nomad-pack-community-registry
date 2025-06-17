# `democratic-csi` CSI plugin

This pack deploys two jobs that run the
[`democratic-csi`](https://github.com/democratic-csi/democratic-csi)
CSI plugin. The node plugin tasks will be run as a system job, and the
controller tasks will be run as a service job.

## Client Requirements

This pack can only be run on Nomad clients that have enabled volumes and
privileged mode for the Docker task driver. In addition, clients will
need to have a source NFS volume mounted to any client host that runs
the controller task.

### Example NFS Server

The following is an example of installing and configuring a NFS server
on an apt-based Linux distribution (ex. Debian or Ubuntu). This
configuration exports the directory `/var/nfs/general` to any Nomad
client on the `192.168.56.0/24` address space (this is commonly used
for Vagrant hosts on Virtualbox).

```sh
sudo apt-get install nfs-kernel-server
sudo mkdir /var/nfs/general

sudo cat <<EOF > /etc/exports
/var/nfs/general 192.168.56.0/24(rw,sync,no_subtree_check,no_root_squash)
EOF

sudo systemctl enable nfs-kernel-server
sudo systemctl start nfs-kernel-server
```

The `democratic-csi` controller is unusual in needing to mount the NFS
volume because NFS doesn't have a remote API other than filesystem
operations. So this plugin has to have the NFS export bind-mounted
into the plugin container. Any client running the controller will need
to have the NFS export in the host's `/etc/fstab`. The following
configuration is an example for the NFS export shown above, assuming
that the NFS server can be found at IP `192.168.56.60`. The mount
point `/srv/nfs_data` shown here should be used for the
`nfs_controller_mount_path` variable.

```
sudo cat <<EOF >> /etc/fstab
192.168.56.60:/var/nfs/general /srv/nfs_data nfs4 rw,relatime 0 0
EOF

```

## Variables

The following variables are required:

* `nfs_share_host` - The IP address of the host for the NFS share.
* `nfs_share_base_path` - The base directory exported from the NFS
  share host.
* `nfs_controller_mount_path` - The path where the NFS mount is
  mounted as a host volume for the controller plugin.

For example, using the NFS configuration described above:

```sh
nomad-pack plan \
    -var nfs_share_host=192.168.56.60 \
    -var nfs_share_base_path=/var/nfs/general \
    -var nfs_controller_mount_path=/srv/nfs_data \
    .
```

The following variables are optional:

* `job_name` (string "democratic_csi") - The prefix to use as the job
  name for the plugins. For example, if `job_name = "democratic_csi"`,
  the plugin job will be named `democratic_csi_controller`.
* `datacenters` (list(string) ["dc1"]) - A list of datacenters in the
  region which are eligible for task placement.
* `region` (string "global") - The region where the job should be
  placed.
* `plugin_id` (string "org.democratic-csi.nfs") - The ID to register
  in Nomad for the plugin.
* `plugin_namespace` (string "default") - The namespace for the plugin
  job.
* `plugin_image` (string
  "docker.io/democraticcsi/democratic-csi:latest") - The container
  image for `democratic-csi`.
* `plugin_csi_spec_version` (string "1.5.0") - The CSI spec version
  that democratic-csi will comply with.
* `plugin_log_level` (string "debug") - The log level for the plugin.
* `nfs_dir_permissions_mode` (string "0777") - The unix file
  permissions mode for the created volumes.
* `nfs_dir_permissions_user` (string "root") - The unix user that owns
  the created volumes.
* `nfs_dir_permissions_group` (string "root") - The unix group that
  owns the created volumes.
* `controller_count` (number 2) - The number of controller instances
  to be deployed (at least 2 recommended).
* `volume_id` (string "myvolume") - ID for the example volume spec to
  output.
* `volume_namespace` (string "default") - Namespace for the example
  volume spec to output.

#### `constraints` List of Objects

[Nomad job specification
constraints](https://www.nomadproject.io/docs/job-specification/constraint)
allow restricting the set of eligible nodes on which the tasks will
run. This pack automatically configures the following required
constraints:

* Plugin tasks will run on Linux hosts only
* Plugin tasks will run on hosts with the Docker driver's
  [`volumes`](https://www.nomadproject.io/docs/drivers/docker#volumes-1)
  enabled and
  [`allow_privileged`](https://www.nomadproject.io/docs/drivers/docker#allow_privileged)
  set to `true`.
* The controller plugin tasks will be deployed on distinct hosts.

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
nomad-pack run -var 'constraints=[{"attribute":"$${meta.my_custom_value}","operator":">","value":"3"}]' packs/democratic_csi_nfs
```

#### `resources` Object

* `cpu` (number 500) - Specifies the CPU required to run this task in
  MHz.
* `memory` (number 256) - Specifies the memory required in MB.

## Volume creation

This pack outputs an example volume specification based on the plugin variables.

#### **`volume.hcl`**

```hcl
type         = "csi"
id           = "my_volume"
namespace    = "default"
name         = "my_volume"
plugin_id    = "org.democratic-csi.nfs"

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
```

Create this volume with the following command:

```sh
nomad volume create volume.hcl
```

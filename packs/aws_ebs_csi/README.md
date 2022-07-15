# AWS EBS CSI plugin

This pack deploys two jobs that run the [AWS
EBS](https://github.com/kubernetes-sigs/aws-ebs-csi-driver) CSI
plugin. The node plugin tasks will be run as a system job, and the
controller tasks will be run as a service job.

## Client Requirements

This pack can only be run on Nomad clients that have enabled volumes
and privileged mode for the Docker task driver. In addition, clients
will need to be deployed in every availability zone where you intend
to create volumes.

## Variables

* `job_name` (string "democratic_csi") - The prefix to use as the job
  name for the plugins. For exmaple, if `job_name = "democratic_csi"`,
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
  "public.ecr.aws/ebs-csi-driver/aws-ebs-csi-driver:v1.5.1") - The container
  image for the plugin.
* `plugin_csi_spec_version` (string "1.5.0") - The CSI spec version
  that democratic-csi will comply with.
* `plugin_log_level` (string "debug") - The log level for the plugin.
* `availability_zones` (list(string) ["us-east-1b"]) - AWS
  availability zones for the node plugins and example volume output.
* `controller_count` (number 2) - The number of controller instances
  to be deployed (at least 2 recommended).
* `volume_id` (string "myvolume") - ID for the example volume spec to
  output.
* `volume_namespace` (string "default") - Namespace for the example
  volume spec to output.
* `volume_min_capacity` (string "10GiB") - Minimum capacity for the example volume spec to output.
* `volume_max_capacity` (string "30GiB") - Maximum capacity for the example volume spec to output.
* `volume_type` (string "gp2") - AWS EBS volume type.

#### `constraints` List of Objects

[Nomad job specification
constraints](https://www.nomadproject.io/docs/job-specification/constraint)
allow restricting the set of eligible nodes on which the tasks will
run. This pack automatically configures the following required
constraints:

* Plugin tasks will run on Linux hosts only
* The node plugin tasks will run on hosts with the Docker driver's
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

Below is also an example of how to pass `constraints` to the CLI with
with the `-var` argument.

```bash
nomad-pack run -var 'constraints=[{"attribute":"$${meta.my_custom_value}","operator":">","value":"3"}]' packs/aws_ebs_csi
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
id           = "myvolume"
namespace    = "default"
plugin_id    = "ebs.csi.aws.com"

# this is used as the AWS EBS volume's CSIVolumeName tag, and
# must be unique per region
name         = "eecede36-6de0-4de1-9a06-6d201c29e2a2"

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

parameters {
  type = "gp2"
}

topology_request {
  required {
    topology {
      segments {

        "topology.ebs.csi.aws.com/zone" = "us-east-1a"
        "topology.ebs.csi.aws.com/zone" = "us-east-1b"
      }
    }
  }
}
```

Create this volume with the following command:

```sh
nomad volume create volume.hcl
```

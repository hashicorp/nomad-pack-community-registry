# AWS EFS CSI plugin

This pack contains a single system job that runs the AWS EFS CSI plugin. It will run the nodes in
monolith modes, which means they will run as both nodes and controllers. The job can only be run
on Nomad hosts which have enabled privileged mode for Docker. In addition the hosts will need to have to
be provided with access to AWS EFS through AWS IAM.

## Variables

- `job_name` (string "aws-efs-csi-nodes") - The name to use as the job name.
- `datacenters` (list(string) ["dc1"]) - A list of datacenters in the region which are eligible for
  task placement.
- `region` (string "global") - The region where the job should be placed.
- `constraints` (list(object)) - Constraints to apply to the entire job.
- `resources` (object) - The resource to assign to the plugin task.
- `image` (string "amazon/aws-efs-csi-driver:master") - The Docker image to run on the plugin tasks.
- `csi_id` (string "aws-efs") - The CSI ID to use for this plugin.

### `constraints` List of Objects

[Nomad job specification constraints](https://www.nomadproject.io/docs/job-specification/constraint) allows restricting the set of eligible nodes
on node task will run.

- `attribute` (string) - Specifies the name or reference of the attribute to examine for the
  constraint.
- `operator` (string) - Specifies the comparison operator. The ordering is compared lexically.
- `value` (string) - Specifies the value to compare the attribute against using the specified
  operation.

By default the job will run on hosts running linux and having Docker privileged mode enabled. The HCL
variable list of objects for the default configuration is shown below and uses a double dollar sign for escaping:
```hcl
[
    {
      attribute = "$${attr.kernel.name}",
      value     = "linux",
      operator  = null,
    },
    {
      attribute = "$${attr.driver.docker.privileged.enabled}",
      value     = true,
      operator  = null,
    }
]
```

### `resources` Object

- `cpu` (number 100) - Specifies the CPU required to run this task in MHz.
- `memory` (number 128) - Specifies the memory required in MB.


## Volume creation example
The plugin currently only by creating new access points to existing EFS file systems. So you'll first have
to provision a new EFS file system. The capacity in the volume spec is not used, but is required by the
CSI Volume API.

#### **`volume.hcl`**
```hcl
id = "test"
name = "Test"
type = "csi"
plugin_id = "aws-efs"
capacity_max = "1G"
capacity_min = "1M"

capability {
	access_mode = "single-node-writer"
	attachment_mode = "file-system"
}

parameters {
	provisioningMode = "efs-ap"
	fileSystemId = "<insert-your-efs-id>"
	directoryPerms = "700"
	gidRangeStart = "1000"
	gidRangeEnd = "2000"
	basePath = "/test"
}
```
Run the command:
```sh
nomad volume create volume.hcl
```

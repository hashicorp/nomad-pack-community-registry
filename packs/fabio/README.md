# Fabio

This pack contains a single system job that runs [Fabio](https://fabiolb.net/) across all Nomad
clients.

Add a tag with `urlprefix-/<PATH>` to the `service` stanzas for Fabio-enabled Nomad services. The
following tag would route fabio to the defined service if the url path started with "/myapp".

```
service {
  ...
  tags = ["urlprefix-/myapp"]
  ...
}
```

See the [Load Balancing with Fabio](https://learn.hashicorp.com/tutorials/nomad/load-balancing-fabio)
tutorial or the [Fabio Homepage](https://fabiolb.net/) for more information.

## Variables

- `job_name` (string "") - The name to use as the job name which overrides using the pack name.
- `datacenters` (list(string) ["dc1"]) - A list of datacenters in the region which are eligible for
task placement.
- `region` (string "global") - The region where the job should be placed.
- `namespace` (string "default") - The namespace where the job should be placed.
- `constraints` (list(object)) - Constraints to apply to the entire job.
- `fabio_group_network` (object) - The Fabio network configuration options.
- `fabio_task_config` (object) - Configuration options to use for the Fabio task driver config.
- `fabio_task_app_properties` (string "") - The contents of a Fabio properties file to pass to the
Fabio app.
- `fabio_task_resources` (object) The resource to assign to the Fabio task.

### `constraints` List of Objects

[Nomad job specification constraints][job_constraint] allows restricting the set of eligible nodes
on which the Fabio task will run.

- `attribute` (string) - Specifies the name or reference of the attribute to examine for the
  constraint.
- `operator` (string) - Specifies the comparison operator. The ordering is compared lexically.
- `value` (string) - Specifies the value to compare the attribute against using the specified
  operation.

The default value constrains the job to run on client whose kernel name is `linux`. The HCL
variable list of objects is shown below and uses a double dollar sign for escaping:
```hcl
[
  {
    attribute = "$${attr.kernel.name}",
    value     = "linux",
    operator  = "",
  }
]
```

### `fabio_group_network` Object

- `mode` (string "host") - Mode of the network.
- `ports` (map<string|number> http:9999,ui:9998) - Specifies the port mapping for the Fabio task.
The map key indicates the port label, and the value is the Fabio port inside the network
namespace. The default value `9999` and `9998` represent the HTTP router and Fabio UI respectively.

### `fabio_task_config` Object

- `version` (string "1.5.15-go1.15.5") - The version of the Fabio application to run.

### `fabio_task_resources` Object

-`cpu` (number 500) - Specifies the CPU required to run this task in MHz.
-`memory` (number 256) - Specifies the memory required in MB.

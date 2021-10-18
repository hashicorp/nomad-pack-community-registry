# Traefik

This pack contains a single system job that runs Traefik across all eligible Nomad clients. It
currently supports being run by the [Docker][docker_driver]. See the
[Load Balancing with Traefik][traefik_learn_guide] tutorial for more information.

## Variables

- `job_name` (string "") - The name to use as the job name which overrides using the pack name.
- `datacenters` (list(string) ["dc1"]) - A list of datacenters in the region which are eligible for
  task placement.
- `region` (string "global") - The region where the job should be placed.
- `namespace` (string "default") - The namespace where the job should be placed.
- `constraints` (list(object)) - Constraints to apply to the entire job.
- `traefik_group_network` (object) - The Traefik network configuration options.
- `traefik_task` (object) - Details configuration options for the Traefik task.
- `traefik_task_app_config` (string) - The Traefik TOML configuration to pass to the
task.
- `traefik_task_resources` (object) - The resource to assign to the Traefik task.
- `traefik_task_services` (list(object)) - Configuration options of the Traefik services and checks.

### `constraints` List of Objects

[Nomad job specification constraints][job_constraint] allows restricting the set of eligible nodes
on which the Traefik task will run.

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

### `traefik_group_network` Object

- `mode` (string "bridge") - Mode of the network.
- `ports` (map<string|number> http:8080,api:1936) - Specifies the port mapping for the Traefik task.
The map key indicates the port label, and the value is the Traefik port inside the network
namespace. The default value `8080` and `1936` represent the HTTP router and Traefik UI respectively.

### `traefik_task` Object

- `driver` (string "docker") - The Nomad task driver to use to run the Traefik task. Currently,
  only "docker" is supported.
- `version` (string "2.30.2") - The Traefik version to run.

### `traefik_task_resources` Object

-`cpu` (number 500) - Specifies the CPU required to run this task in MHz.
-`memory` (number 256) - Specifies the memory required in MB.

### `traefik_task_services` List of Objects

- `service_port_label` (string) - Specifies the port to advertise for this service.
- `service_name` (string) - Specifies the name this service will be advertised as in Consul.
- `service_tags` (list(string)) - Specifies the list of tags to associate with this service.
- `check_enabled` (bool) - Whether to enable a check for this service.
- `check_type` (string) - The type of check to configure.
- `check_path` (string) - The HTTP path to query, if `check_type` is set to `http`.
- `check_interval` (string) - Specifies the frequency of the health checks that Consul will perform.
- `check_timeout` (string)-  Specifies how long Consul will wait for a health check query to succeed.

The default value for this variable configures a service and a check for both the ports configured
by default within the `traefik_group_network.ports` mapping.

[traefik_learn_guide]: (https://learn.hashicorp.com/tutorials/nomad/load-balancing-traefik)
[docker_driver]: (https://www.nomadproject.io/docs/drivers/docker)

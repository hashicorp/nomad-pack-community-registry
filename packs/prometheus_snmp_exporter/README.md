# Prometheus SNMP exporter

This pack can be used to run [Prometheus SNMP exporter][prom_snmp_exporter]. It currently supports
being run by the [Docker driver][docker_driver].

## Variables

- `job_name` (string "") - The name to use as the job name which overrides using the pack name.
- `datacenters` (list(string) ["dc1"]) - A list of datacenters in the region which are eligible for task placement.
- `region` (string "global") - The region where the job should be placed.
- `namespace` (string "default") - The namespace where the job should be placed.
- `constraints` (list(object)) - Constraints to apply to the entire job.
- `job_type` (string "service") - The type of the job.
- `instance_count` (number 1) - In case the job is ran as a service, how many copies of the snmp_exporter group to run.
- `snmp_exporter_group_network` (object) - The SNMP exporter network configuration options.
- `snmp_exporter_task_config` (object) - The SNMP exporter task config options.
- `snmp_exporter_task_resources` (object) - The resource to assign to the SNMP exporter task.
- `snmp_exporter_task_services` (object) - Configuration options of the SNMP exporter services and checks.

### `constraints` List of Objects

[Nomad job specification constraints][job_constraint] allows restricting the set of eligible nodes
on which the SNMP exporter task will run.

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

### `snmp_exporter_group_network` Object

- `mode` (string "bridge") - Mode of the network.
- `ports` (map<string|number> http:9116) - Specifies the port mapping for the SNMP exporter task. The map key indicates the port label, and the value is the SNMP exporter port inside the network namespace.

### `snmp_exporter_task_config` Object

- `image` (string "prom/snmp-exporter") - The name of the docker image to run.
- `version` (string "v0.20.0") - The SNMP exporter version to run.

### `snmp_exporter_task_resources` Object

-`cpu` (number 100) - Specifies the CPU required to run this task in MHz.
-`memory` (number 64) - Specifies the memory required in MB.

### `snmp_exporter_task_services` List of Objects

- `service_port_label` (string) - Specifies the port to advertise for this service.
- `service_name` (string) - Specifies the name this service will be advertised as in Consul.
- `service_tags` (list(string)) - Specifies the list of tags to associate with this service.
- `check_enabled` (bool) - Whether to enable a check for this service.
- `check_path` (string) - The HTTP path to query SNMP exporter.
- `check_interval` (string) - Specifies the frequency of the health checks that Consul will perform.
- `check_timeout` (string) - Specifies how long Consul will wait for a health check query to succeed.

The default value for this variable configures a service for the SNMP exporter along with a check.
```hcl
[
  {
    service_port_label = "http",
    service_name       = "prometheus-snmp-exporter",
    service_tags       = [],
    check_enabled      = true,
    check_path         = "/",
    check_interval     = "30s",
    check_timeout      = "30s",
  }
]
```

[job_constraint]: (https://www.nomadproject.io/docs/job-specification/constraint)
[prom_snmp_exporter]: (https://github.com/prometheus/snmp_exporter)
[docker_driver]: (https://www.nomadproject.io/docs/drivers/docker)

# Prometheus

This pack can be used to run [Prometheus][prometheus] on your Nomad cluster. It currently supports
being run by the [Docker][docker_driver] and allows for Prometheus to be configured in different
ways.

## Variables

- `job_name` (string "") - The name to use as the job name which overrides using the pack name.
- `datacenters` (list(string) ["dc1"]) - A list of datacenters in the region which are eligible for
  task placement.
- `region` (string "global") - The region where the job should be placed.
- `namespace` (string "default") - The namespace where the job should be placed.
- `constraints` (list(object)) - Constraints to apply to the entire job.
- `prometheus_group_network` (object) - The Prometheus network configuration options.
- `prometheus_task` (object) - Details configuration options for the Prometheus task.
- `prometheus_task_app_prometheus_yaml` (string) - The Prometheus configuration to pass to the
task. The default value includes scrape configuration for Nomad servers, Nomad client, and
Prometheus.
- `prometheus_task_app_rules_yaml` (string) - Configuration for the alerts to be setup in prometheus.
An example config is included in the alers_vars.nomad file.
- `prometheus_task_resources` (object) - The resource to assign to the Prometheus task.
- `prometheus_task_services` (object) - Configuration options of the Prometheus services and checks.

### `constraints` List of Objects

[Nomad job specification constraints][job_constraint] allows restricting the set of eligible nodes
on which the Prometheus task will run.

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

### `prometheus_group_network` Object

- `mode` (string "bridge") - Mode of the network.
- `ports` (map<string|number> http:9090) - Specifies the port mapping for the Prometheus task. The
map key indicates the port label, and the value is the Prometheus port inside the network namespace.

### `prometheus_task` Object

- `driver` (string "docker") - The Nomad task driver to use to run the Prometheus task. Currently,
only "docker" is supported.
- `version` (string "2.30.2") - The Prometheus version to run.
- `cli_args` (list(string) "<see_below>") - A list of CLI arguments to pass to Prometheus.

The default CLI arguments pass to Prometheus:
```hcl
[
  "--config.file=/etc/prometheus/config/prometheus.yml",
  "--storage.tsdb.path=/prometheus",
  "--web.listen-address=0.0.0.0:9090",
  "--web.console.libraries=/usr/share/prometheus/console_libraries",
  "--web.console.templates=/usr/share/prometheus/consoles",
]
```

### `prometheus_task_resources` Object

-`cpu` (number 500) - Specifies the CPU required to run this task in MHz.
-`memory` (number 256) - Specifies the memory required in MB.

### `prometheus_task_services` List of Objects

- `service_port_label` (string) - Specifies the port to advertise for this service.
- `service_name` (string) - Specifies the name this service will be advertised as in Consul.
- `service_tags` (list(string)) - Specifies the list of tags to associate with this service.
- `check_enabled` (bool) - Whether to enable a check for this service.
- `check_path` (string) - The HTTP path to query Prometheus.
- `check_interval` (string) - Specifies the frequency of the health checks that Consul will perform.
- `check_timeout` (string) - Specifies how long Consul will wait for a health check query to succeed.

The default value for this variable configures a service for the Prometheus API along with a check
running against the Prometheus [management API][prometheus_management_api] health check endpoint.
```hcl
[
  {
    service_port_label = "http",
    service_name       = "prometheus",
    service_tags       = [],
    check_enabled      = true,
    check_path         = "/-/healthy",
    check_interval     = "3s",
    check_timeout      = "1s",
  }
]
```

[prometheus]: (https://prometheus.io/)
[prometheus_management_api]: (https://prometheus.io/docs/prometheus/latest/management_api/)
[docker_driver]: (https://www.nomadproject.io/docs/drivers/docker)
[job_constraint]: (https://www.nomadproject.io/docs/job-specification/constraint)

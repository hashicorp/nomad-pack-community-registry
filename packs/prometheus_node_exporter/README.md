# Prometheus Node Exporter

This pack contains a single system job that runs
[Prometheus Node Exporter](https://prometheus.io/docs/guides/node-exporter/) across all eligible
Nomad clients. It currently supports being run by the [Docker driver](https://www.nomadproject.io/docs/drivers/docker).

Clients that expect to run this job require Docker volumes to be enabled within their client config
stanza.
```hcl
client {
  options = {
    "docker.volumes.enabled" = true
  }
}
```

The node exporter task registers a Consul service and health check by default. Once running, your
Prometheus configuration can be updated with the following scrape config entry which will allow
Prometheus to discover and scrape all deployed node exporter instances.
```yaml
- job_name: "node_exporter"
  metrics_path: "/metrics"
  consul_sd_configs:
    - server: "consul.example.com:8500"
      services:
        - "prometheus-node-exporter"
```

## Variables

- `job_name` (string "") - The name to use as the job name which overrides using the pack name.
- `datacenters` (list(string) ["dc1"]) - A list of datacenters in the region which are eligible for
  task placement.
- `region` (string "global") - The region where the job should be placed.
- `namespace` (string "default") - The namespace where the job should be placed.
- `constraints` (list(object)) - Constraints to apply to the entire job.
- `node_exporter_group_network` (object) - The node exporter network configuration options.
- `node_exporter_task_config` (object) - The node exporter task config options.
- `node_exporter_task_resources` (object) - The resource to assign to the node exporter task.
- `node_exporter_task_services` (object) - Configuration options of the node exporter services and
checks.

### `constraints` List of Objects

[Nomad job specification constraints][job_constraint] allows restricting the set of eligible nodes
on which the Prometheus Node Exporter task will run.

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

### `node_exporter_group_network` Object

- `mode` (string "bridge") - Mode of the network.
- `ports` (map<string|number> http:9100) - Specifies the port mapping for the node exporter task.

### `node_exporter_task_config` Object

- `version` (string "v1.2.2") - The Prometheus Node Exporter version to run.

### `node_exporter_task_resources` Object

-`cpu` (number 100) - Specifies the CPU required to run this task in MHz.
-`memory` (number 128) - Specifies the memory required in MB.

### `node_exporter_task_services` List of Objects

- `service_port_label` (string) - Specifies the port to advertise for this service.
- `service_name` (string) - Specifies the name this service will be advertised as in Consul.
- `service_tags` (list(string)) - Specifies the list of tags to associate with this service.
- `check_enabled` (bool) - Whether to enable a check for this service.
- `check_type` (string) - The type of check to configure.
- `check_interval` (string) - Specifies the frequency of the health checks that Consul will perform.
- `check_timeout` (string)-  Specifies how long Consul will wait for a health check query to succeed.

The default value for this variable configures a service and a check for the node exporter `http` port
defined as default within the `node_exporter_group_network.ports` mapping.

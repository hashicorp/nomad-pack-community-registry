# Vector

This pack contains a single system job that runs [Vector](https://vector.dev) across all Nomad clients. It currently supports
being run by the [Docker](https://www.nomadproject.io/docs/drivers/docker) driver.

The inbuilt configuration file is configured to read from 3 sources:
- **Docker logs:** [*(reference)*](https://vector.dev/docs/reference/configuration/sources/docker_logs/) plugs into the Docker socket to collect container logs;
- **Host metrics:** [*(reference)*](https://vector.dev/docs/reference/configuration/sources/host_metrics/) collects host metrics, such as CPU, memory, disk, and network utilization with Vector's inbuilt collector;
- **Nomad metrics:** [*(reference)*](https://www.nomadproject.io/docs/operations/metrics) collects exposed Nomad metrics via the Prometheus client.

Additionally, Docker logs will be sent to the specified [Loki](https://vector.dev/docs/reference/configuration/sinks/loki/) endpoint (with support for basic authentication) and host/Nomad metrics to the specified [Prometheus](https://vector.dev/docs/reference/configuration/sinks/prometheus_remote_write/) endpoint (also with support for basic authentication).

## Requirements
### Loki and Prometheus
Running instances of Loki and Prometheus are required and are not deployed with this pack.

Vector will collect:
  - Docker logs: forwarding them to a running Loki instance;
  - Host metrics: forwarding them to a running Prometheus instance.

Nomad packs for [Loki](https://github.com/hashicorp/nomad-pack-community-registry/tree/main/packs/loki) and [Prometheus](https://github.com/hashicorp/nomad-pack-community-registry/tree/main/packs/prometheus) are readily available for a self-hosted solution.

[Grafana Cloud](https://grafana.com/products/cloud/), Grafana Labs' managed service, is also supported by this pack with basic authentication.

### Nomad
Clients that expect to run this job require:
- Docker volumes to be enabled within their Docker plugin stanza, due to read-only bind mounts of /proc, /sys and /var/run/docker.sock:
```hcl
plugin "docker" {
  config {
    volumes {
      enabled = true
    }
  }
}
```
- Extra Docker labels to be added within their Docker plugin stanza, in order to facilitate logs filtering:
```hcl
plugin "docker" {
  config {
    extra_labels = ["job_name", "job_id", "task_group_name", "task_name", "namespace", "node_name", "node_id"]
  }
}
```
- Telemetry to be enabled within their config stanza:
```hcl
telemetry {
  collection_interval = "5s"
  disable_hostname = false
  prometheus_metrics = true
  publish_allocation_metrics = true
  publish_node_metrics = true
}
```
- [CNI plugins installed](https://www.nomadproject.io/docs/job-specification/network#network-modes "CNI plugins installed") and [its path](https://www.nomadproject.io/docs/configuration/client#cni_path "its path") set in the client's configuration if network mode is set to bridge.

## Variables

- `job_name` (string "") - The name to use as the job name which overrides using the pack name.
- `datacenters` (list(string) ["dc1"]) - A list of datacenters in the region which are eligible for task placement.
- `region` (string "global") - The region where the job should be placed.
- `namespace` (string "default") - The namespace where the job should be placed.
- `constraints` (list(object)) - Constraints to apply to the entire job.
- `vector_group_network` (object) - The Vector network configuration options.
- `vector_group_update` (object) - The Vector update configuration options.
- `vector_group_ephemeral_disk` (object) - The Vector ephemeral disk configuration options.
- `vector_task` (object) - Details configuration options for the Vector task.
- `vector_task_bind_mounts` (object) - Details configuration options for the Vector bind mounts.
- `vector_task_loki_prometheus` (object) - Details Loki and Prometheus endpoints/credentials for the Vector task.
- `vector_task_data_config_toml` (string) - The Vector configuration to pass to the
task.
- `vector_task_resources` (object) - The resource to assign to the Vector task.
- `vector_task_services` (object) - Configuration options of the Vector service and checks.

### `constraints` List of Objects

[Nomad job constraint stanza](https://www.nomadproject.io/docs/job-specification/constraint) allows restricting the set of eligible nodes on which the Vector task will run.

- `attribute` (string) - Specifies the name or reference of the attribute to examine for the
constraint.
- `operator` (string) - Specifies the comparison operator. The ordering is compared lexically.
- `value` (string) - Specifies the value to compare the attribute against using the specified
operation.

The default value constrains the job to run on client whose kernel name is `linux`. The HCL variable list of objects is shown below and uses a double dollar sign for escaping:
```hcl
[
  {
    attribute = "$${attr.kernel.name}",
    value     = "linux",
    operator  = "",
  }
]
```

### `vector_group_network` Object

[Nomad job network stanza](https://www.nomadproject.io/docs/job-specification/network) specifies the networking requirements for the task group, including the network mode and port allocations.

- `mode` (string "bridge") - Mode of the network.
- `hostname` (string "${attr.unique.hostname}") - Specifies the hostname assigned to the network namespace. If hostname is not specified, the container hostname will be used in the metrics.
- `ports` (map<string|number> api:8686) - Specifies the port mapping for the Vector task. The map key indicates the port label, and the value is the Vector port inside the network namespace.

### `vector_group_update` Object

[Nomad job update stanza](https://www.nomadproject.io/docs/job-specification/update) specifies the networking requirements for the task group, including the network mode and port allocations.

- `min_healthy_time` (string "10s") - The minimum time the allocation must be in the healthy state before it is marked as healthy.
- `healthy_deadline` (string "5m") - The deadline in which the allocation must be marked as healthy after which the allocation is automatically transitioned to unhealthy.
- `progress_deadline` (string "10m") - The deadline in which an allocation must be marked as healthy.
- `auto_revert` (bool "true") - Specifies if the job should auto-revert to the last stable job on deployment failure.

### `vector_group_ephemeral_disk` Object

[Nomad job ephemeral disk stanza](https://www.nomadproject.io/docs/job-specification/ephemeral_disk) describes the ephemeral disk requirements of the group.

- `migrate` (bool true) - Specifies that the Nomad client should make a best-effort attempt to migrate the data from a remote machine if placement cannot be made on the original node.
- `size` (number 300) - Specifies the size of the ephemeral disk in MB.
- `sticky` (bool true) - Specifies that Nomad should make a best-effort attempt to place the updated allocation on the same machine.

### `vector_task` Object

- `driver` (string "docker") - The Nomad task driver to use to run the Vector task. Currently, only "docker" is supported.
- `version` (string "0.17.3-alpine") - The Vector version to run.

### `vector_task_bind_mounts` Object

Details configuration options for the Vector bind mounts. Three directories are mounted into the container and there are 2 variables exposed for each bind mount: [the source and target paths](https://www.nomadproject.io/docs/drivers/docker#mount).

- `source_procfs_root_path` (string "/proc") - The absolute path for the procfs in the host (node).
- `source_sysfs_root_path` (string "/sys") - The absolute path for the sysfs in the host (node).
- `source_docker_socket_path` (string "/var/run/docker.sock") - The absolute path for the Docker socket in the host (node).
- `target_procfs_root_path` (string "/host/proc") - The absolute path for the procfs mount in the container's filesystem.
- `target_sysfs_root_path` (string "/host/sys") - The absolute path for the sysfs mount in the container's filesystem.
- `target_docker_socket_path` (string "/host/var/run/docker.sock") - The absolute path for the Docker socket mount in the container's filesystem.

### `vector_task_loki_prometheus` Object

Details endpoints and credentials for the Loki and Prometheus instances that Vector will send data to.

- `loki_endpoint_url` (string "http://127.0.0.1:3100") - Loki's endpoint URL. In case the logs are to be sent to Grafana Cloud, use the base URL. For example: ```https://logs-prod-eu-west-0.grafana.net/```.
- `loki_username` (string "") - Loki's basic authentication username.
- `loki_password` (string "") - Loki's basic authentication password.
- `prometheus_endpoint_url` (string "http://127.0.0.1:9090") - Prometheus's remote write endpoint URL. In case the logs are to be sent to Grafana Cloud, use the remote write URL. For example: ```https://prometheus-prod-01-eu-west-0.grafana.net/api/prom/push```.
- `prometheus_username` (string "") - Prometheus' basic authentication username.
- `prometheus_password` (string "") - Prometheus' basic authentication password.

### `vector_task_resources` Object

-`cpu` (number 64) - Specifies the CPU required to run this task in MHz.
-`memory` (number 64) - Specifies the memory required in MB.

### `vector_task_services` List of Objects

- `service_port_label` (string "api") - Specifies the port to advertise for this service.
- `service_name` (string "vector") - Specifies the name this service will be advertised as in Consul.
- `service_tags` (list(string) ["observability"]) - Specifies the list of tags to associate with this service.
- `check_enabled` (bool true) - Whether to enable a check for this service.
- `check_path` (string "/health") - The HTTP path to query Vector's API.
- `check_interval` (string "3s") - Specifies the frequency of the health checks that Consul will perform.
- `check_timeout` (string "1s") - Specifies how long Consul will wait for a health check query to succeed.

The default value for this variable configures a service for the Vector API along with a check running against the Vector API [health check endpoint](https://vector.dev/docs/reference/api/).
```hcl
[
  {
    service_port_label = "api",
    service_name       = "vector",
    service_tags       = ["observability"],
    check_enabled      = true,
    check_path         = "/health",
    check_interval     = "3s",
    check_timeout      = "1s",
  }
]
```

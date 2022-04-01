# Redis

[Redis](https://redis.io/docs/getting-started/) is an open-source, networked, in-memory, key-value data store with optional durability.

This pack deploys Redis server to Nomad as a standard service with the option to specify how many instances to create.

## Dependencies

This pack requires Linux clients to run properly.

## Configuration

This pack can be run without any additional configuration. See `Variables` below for custom options.

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_constraints"></a> [constraints](#input\_constraints) | Constraints to apply to the entire job. | ```list(object({ attribute = string operator = string value = string }))``` | `[]` | no |
| <a name="input_datacenters"></a> [datacenters](#input\_datacenters) | A list of datacenters in the region which are eligible for task placement. | `list(string)` | ```[ "dc1" ]``` | no |
| <a name="input_job_name"></a> [job\_name](#input\_job\_name) | The name to use as the job name which overrides using the pack name. | `string` | `""` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace where the job should be placed. | `string` | `"default"` | no |
| <a name="input_redis_group_name"></a> [redis\_group\_name](#input\_redis\_group\_name) | Optionally apply a custom name for the redis task group. | `string` | `"server"` | no |
| <a name="input_redis_group_network"></a> [redis\_group\_network](#input\_redis\_group\_network) | The redis network configuration options. | ```object({ mode = string ports = map(number) })``` | ```{ "mode": "bridged", "ports": { "http": 6379 } }``` | no |
| <a name="input_redis_group_services"></a> [redis\_group\_services](#input\_redis\_group\_services) | Configuration options of the redis services and checks. | ```list(object({ service_port_label = string service_name = string service_tags = list(string) check_enabled = bool check_path = string check_interval = string check_timeout = string upstreams = list(object({ name = string port = number })) }))``` | ```[ { "check_enabled": true, "check_interval": "3s", "check_path": "/ready", "check_timeout": "1s", "service_name": "redis", "service_port_label": "http", "service_tags": [], "upstreams": [] } ]``` | no |
| <a name="input_redis_task_args"></a> [redis\_task\_args](#input\_redis\_task\_args) | Optionally provide custom arguments to the redis task. | `list(string)` | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | The region where the job should be placed. | `string` | `"global"` | no |
| <a name="input_resources"></a> [resources](#input\_resources) | The resource to assign to the redis service task. | ```object({ cpu = number memory = number })``` | ```{ "cpu": 200, "memory": 256 }``` | no |
| <a name="input_server_count"></a> [server\_count](#input\_server\_count) | The number of Redis server instances to create. | `number` | `1` | no |
| <a name="input_version_tag"></a> [version\_tag](#input\_version\_tag) | The docker image version. For options, see https://hub.docker.com/_/redis?tab=tags | `string` | `"latest"` | no |
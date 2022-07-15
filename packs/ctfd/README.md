# CTFd

This pack contains all you need to deploy CTFd in Nomad. It uses the Docker driver and spins up these services:

| Service | Default version |
| ------- | --------------- |
| CTFd | 3.3.1 |
| MariaDB | 10 |
| Redis | 6 |

## Dependencies

This pack requires the Docker driver to be enabled and R/W access to the following pre-existing volumes, the names and types of which can be specified through the pack's variables:

| Volume's variable name | Description |
| ---------------------- | ----------- |
| `uploads_volume_name` | Where to store files uploaded through CTFd (ex.: challenges' attachments). |
| `mariadb_volume_name` | MariaDB data storage. |
| `redis_volume_name` | Redis data and periodic backup storage. |

It also relies on an existing Consul integration for health checking and service discovery.

## Variables

| Name | Type | Default value | Description |
| ---- | ---- | ------------- | ----------- |
| `job_name` | _string_ | "ctfd" | The name to use as the job name which overrides using the pack name. |
| `region` | _string_ | "" | The region where jobs will be deployed. |
| `datacenters` | _list("string")_ | ["dc1"] | A list of datacenters in the region which are eligible for task placement. |
| `namespace` | _string_ | _N/A_ | The namespace where the job should be placed. |
| `register_consul_service` | _bool_ | "False" | If you want to register a Consul service for the job. |
| `consul_service_name` | _string_ | "ctfd" | The consul service name for the application. |
| `consul_service_tags` | _list("string")_ | ["ctfd"] | The consul service tags for the application. |
| `uploads_volume_name` | _string_ | "ctfd_uploads" | The name of the dedicated data volume you want CTFd to store file uploads into. |
| `uploads_volume_type` | _string_ | "host" | The type of the dedicated data volume you want CTFd to store file uploads into. |
| `mariadb_volume_name` | _string_ | "ctfd_mariadb" | The name of the dedicated data volume you want MariaDB to store data into. |
| `mariadb_volume_type` | _string_ | "host" | The type of the dedicated data volume you want MariaDB to store data into. |
| `redis_volume_name` | _string_ | "ctfd_redis" | The name of the dedicated data volume you want Redis to store data into. |
| `redis_volume_type` | _string_ | "host" | The type of the dedicated data volume you want Redis to store data into. |
| `ctfd_resources` | _object({cpu:"number",memory:"number"})_ | {cpu: 250, memory: 500} | The resources reserved for CTFd itself. |
| `ctfd_image_name` | _string_ | "ctfd/ctfd" | The CTFd Docker image name to pull. |
| `ctfd_image_tag` | _string_ | "3.3.1-release" | The CTFd Docker image tag to pull. |
| `ctfd_port` | _number_ | _N/A_ | The static host port that CTFd will be served on. If not specified, an external reverse proxy will be needed. |
| `ctfd_expect_reverse_proxy` | _bool_ | "False" | If you want CTFd to expect being behind a reverse proxy. |
| `mariadb_resources` | _object({cpu:"number",memory:"number"})_ | {cpu: 250, memory: 500} | The resources reserved for MariaDB. |
| `mariadb_image_name` | _string_ | "mariadb" | The MariaDB Docker image name to pull. |
| `mariadb_image_tag` | _string_ | "10" | The MariaDB Docker image tag to pull. |
| `mariadb_root_password` | _string_ | "ctfd" | The password that will be used for the 'root' MariaDB user. |
| `mariadb_ctfd_password` | _string_ | "ctfd" | The password that will be used to create the 'ctfd' MariaDB user. |
| `redis_resources` | _object({cpu:"number",memory:"number"})_ | {cpu: 250, memory: 500} | The resources reserved for Redis. |
| `redis_image_name` | _string_ | "redis" | The Redis Docker image name to pull. |
| `redis_image_tag` | _string_ | "6" | The Redis Docker image tag to pull. |

## Example run

> `nomad-pack run . --var=datacenters='["dc1"]' --var ctfd_port=8888`

Note: the contents of the host volumes aren't erased, if the deployment fails double check that they don't contain old/invalid data.

## Initial setup

Refer to CTFd's official [Getting started](https://docs.ctfd.io/tutorials/getting-started/) docs for guidance once the stack is running.

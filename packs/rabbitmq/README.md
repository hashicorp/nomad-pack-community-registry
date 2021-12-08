# RabbitMQ Secure Cluster

This pack contains a RabbitMQ cluster, configured to use TLS (by default, using certificates from Vault).

It has a requirement of Consul being available, as it is used for clustering/node discovery.

This pack makes use of two files stored in the Task's local volume; `rabbitmq.conf` and `enabled_plugins`.  There shouldn't be any need to touch these files directly, as you can modify both through the variables `extra_conf` and `enabled_plugins` respectively.

## Configuration

| Name | Required | Default | Comments |
|------|----------|---------|----------|
| `job_name` | no | `"rabbit"` | Override the Nomad job name |
| `datacenters` | no | `"dc1"` |  |
| `cluster_size` | no | `3` | This should be an odd number |
| `consul_service_amqp_tags` | no | `["amqp"]` |
| `consul_service_management_tags` | no | `["management"]` |
| `vault_enabled` | no | `true` |
| `vault_roles` | no | `["rabbit"]` |
| `image` | no | `"rabbitmq:3.9.10-management-alpine"`  |
| `enabled_plugins` |  no | `["rabbitmq_management"]` | The `rabbitmq_peer_discovery_consul` is always enabled, as it is required for clustering. |
| `extra_conf` | no | `""` | Any extra configuration for the `rabbitmq.conf` file. See [Configuration](https://www.rabbitmq.com/configure.html) |
| `port_amqp` | no | `0` | Setting to `0` causes a random port to be assigned.  `5671` is the default port RabbitMQ uses. |
| `port_ui` | no | `0` | Setting to `0` causes a random port to be assigned |
| `port_discovery` | no | `4369` | The port RabbitMQ uses for node discovery.  Cannot be dynamically assigned. |
| `port_clustering` | no | `25672` | The port RabbitMQ uses for clustering.  Cannot be dynamically assigned. |
| `pki_vault_enabled` | no | `true`  |
| `pki_vault_domain` | yes | `""`  | e.g. `nomad.company.internal` |
| `pki_vault_secret_path` | no |  `"pki/issue/rabbit"` |
| `pki_artifact_ca_cert` | no | `{}` | Only used if `pki_vault_enabled=false`. See [Artifact Stanza](https://www.nomadproject.io/docs/job-specification/artifact) for fields. |
| `pki_artifact_node_cert` | no | `{}` | Only used if `pki_vault_enabled=false`. See [Artifact Stanza](https://www.nomadproject.io/docs/job-specification/artifact) for fields. |
| `pki_artifact_node_cert_key` | no |  `{}` | Only used if `pki_vault_enabled=false`. See [Artifact Stanza](https://www.nomadproject.io/docs/job-specification/artifact) for fields. |
| `cookie_vault` | no | `{}` |
| `cookie_static` | no | `""` |
| `admin_user_vault_enabled` | no | `true` | |
| `admin_user_vault_path` | no | `"secret/data/rabbit/admin"` | |
| `admin_user_vault_username_key` | no | `"username"` | |
| `admin_user_vault_password_key` | no | `"password"` | |
| `admin_user_static_username` | no | `""`  | Only used if `admin_user_vault_enabled=false` |
| `admin_user_static_password` | no | `""`  | Only used if `admin_user_vault_enabled=false` |

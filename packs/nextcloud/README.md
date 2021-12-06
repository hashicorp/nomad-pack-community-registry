# Nextcloud

Nextcloud is a suite of software for productivity and file management.

It is community-driven, free, and open source. It can be thought of as an OSS GSuite.

This Pack contains a Nomad job to deploy a task with the Nextcloud server. Optionally,
it includes two additional tasks to host a postgres database with the Nextcloud on the
same client node.

## Dependencies

This pack requires Linux clients to run properly.

If you choose to use "services", configurable via variables, Consul is required.

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_job_name"></a> [job\_name](#input\_job\_name) | The name to use as the job name which overrides using the pack name. | `string` | `""` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace where the job should be placed. | `string` | `"default"` | no |
| <a name="input_datacenters"></a> [datacenters](#input\_datacenters) | A list of datacenters in the region which are eligible for task placement. | `list(string)` | <pre>[<br>  "dc1"<br>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | The region where the job should be placed. | `string` | `"global"` | no |
| <a name="input_nextcloud_image_tag"></a> [nextcloud\_image\_tag](#input\_nextcloud\_image\_tag) | The docker image tag. For options, see https://hub.docker.com/_/nextcloud | `string` | `"latest"` | no |
| <a name="input_postgres_image_tag"></a> [postgres\_image\_tag](#input\_postgres\_image\_tag) | Tag for postgres image  For options, see https://hub.docker.com/_/postgres | `string` | `"9.6.14"` | no |
| <a name="input_constraints"></a> [constraints](#input\_constraints) | Constraints to apply to the entire job. | <pre>list(object({<br>    attribute = string<br>    operator  = string<br>    value     = string<br>  }))</pre> | <pre>[<br>  {<br>    "attribute": "${attr.kernel.name}",<br>    "operator": "=",<br>    "value": "linux"<br>  }<br>]</pre> | no |
| <a name="input_network"></a> [network](#input\_network) | The group network configuration options. | <pre>object({<br>    mode  = string<br>    ports = list(object({<br>      name   = string<br>      to     = number<br>      static = number<br>    }))<br>  })</pre> | <pre>{<br>  "mode": "bridge",<br>  "ports": [<br>    {<br>      "name": "http",<br>      "static": 4001,<br>      "to": 80<br>    },<br>    {<br>      "name": "db",<br>      "static": 5432,<br>      "to": 5432<br>    }<br>  ]<br>}</pre> | no |
| <a name="input_app_service"></a> [app\_service](#input\_app\_service) | Configuration for the application service. | <pre>object({<br>    service_port_label = string<br>    service_name       = string<br>    service_tags       = list(string)<br>    check_enabled      = bool<br>    check_type         = string<br>    check_path         = string<br>    check_interval     = string<br>    check_timeout      = string<br>    upstreams = list(object({<br>      name = string<br>      port = number<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_db_service"></a> [db\_service](#input\_db\_service) | Configuration for the database service. | <pre>object({<br>    service_port_label = string<br>    service_name       = string<br>    service_tags       = list(string)<br>    check_enabled      = bool<br>    check_type         = string<br>    check_path         = string<br>    check_interval     = string<br>    check_timeout      = string<br>    upstreams = list(object({<br>      name = string<br>      port = number<br>    }))<br>  })</pre> | <pre>{<br>  "check_enabled": true,<br>  "check_interval": "30s",<br>  "check_path": "",<br>  "check_timeout": "2s",<br>  "check_type": "tcp",<br>  "service_name": "nextcloud-db",<br>  "service_port_label": "db",<br>  "service_tags": [<br>    "postgres"<br>  ],<br>  "upstreams": []<br>}</pre> | no |
| <a name="input_app_resources"></a> [app\_resources](#input\_app\_resources) | The resource to assign to the NextCloud app task. | <pre>object({<br>    cpu    = number<br>    memory = number<br>  })</pre> | <pre>{<br>  "cpu": 500,<br>  "memory": 2048<br>}</pre> | no |
| <a name="input_db_resources"></a> [db\_resources](#input\_db\_resources) | The resource to assign to the NextCloud app task. | <pre>object({<br>    cpu    = number<br>    memory = number<br>  })</pre> | <pre>{<br>  "cpu": 100,<br>  "memory": 512<br>}</pre> | no |
| <a name="input_container_args"></a> [container\_args](#input\_container\_args) | Arguments to pass to the Nextcloud container | `list(string)` | `[]` | no |
| <a name="input_env_vars"></a> [env\_vars](#input\_env\_vars) | Nextcloud environment variables. | <pre>list(object({<br>    key   = string<br>    value = string<br>  }))</pre> | <pre>[<br>  {<br>    "key": "NEXTCLOUD_ADMIN_USER",<br>    "value": "admin"<br>  },<br>  {<br>    "key": "NEXTCLOUD_ADMIN_PASSWORD",<br>    "value": "password"<br>  },<br>  {<br>    "key": "NEXTCLOUD_DATA_DIR",<br>    "value": "/var/www/html/data"<br>  }<br>]</pre> | no |
| <a name="input_db_env_vars"></a> [db\_env\_vars](#input\_db\_env\_vars) | Nextcloud environment variables. | <pre>list(object({<br>    key   = string<br>    value = string<br>  }))</pre> | <pre>[<br>  {<br>    "key": "POSTGRES_DB",<br>    "value": "nextcloud"<br>  },<br>  {<br>    "key": "POSTGRES_USER",<br>    "value": "nextcloud"<br>  },<br>  {<br>    "key": "POSTGRES_PASSWORD",<br>    "value": "password"<br>  },<br>  {<br>    "key": "POSTGRES_HOST",<br>    "value": "localhost"<br>  }<br>]</pre> | no |
| <a name="input_app_mounts"></a> [app\_mounts](#input\_app\_mounts) | Mounts that are configured when using the default NextCloud configuration | <pre>list(object({<br>    type     = string<br>    source   = string<br>    target   = string<br>    readonly = bool<br>    bind_options = list(object({<br>      name  = string<br>      value = string<br>    }))<br>  }))</pre> | <pre>[<br>  {<br>    "bind_options": [],<br>    "readonly": false,<br>    "source": "/var/nextcloud/html/data",<br>    "target": "/var/www/html/",<br>    "type": "bind"<br>  }<br>]</pre> | no |
| <a name="input_postgres_mounts"></a> [postgres\_mounts](#input\_postgres\_mounts) | password for postgres database | <pre>list(object({<br>    type     = string<br>    source   = string<br>    target   = string<br>    readonly = bool<br>    bind_options = list(object({<br>      name  = string<br>      value = string<br>    }))<br>  }))</pre> | <pre>[<br>  {<br>    "bind_options": [],<br>    "readonly": false,<br>    "source": "/var/nextcloud/postgresql/data",<br>    "target": "/var/lib/postgresql/data",<br>    "type": "bind"<br>  }<br>]</pre> | no |
| <a name="input_include_database_task"></a> [include\_database\_task](#input\_include\_database\_task) | Whether or not to include a db task. If using a remote database, this should be false. | `bool` | `true` | no |
| <a name="input_prestart_directory_creation"></a> [prestart\_directory\_creation](#input\_prestart\_directory\_creation) | Whether or not to launch a prestart task to create volume directories on the host. | `bool` | `true` | no |
| <a name="input_db_volume_source_path"></a> [db\_volume\_source\_path](#input\_db\_volume\_source\_path) | Volume path on the host machine used for database data | `string` | `"/var/nextcloud/postgresql/data"` | no |
| <a name="input_app_data_source_path"></a> [app\_data\_source\_path](#input\_app\_data\_source\_path) | Volume path on the host machine used for nextcloud application data | `string` | `"/var/nextcloud/html/data"` | no |
# Promtail

[Promtail](https://grafana.com/docs/loki/latest/clients/promtail/) is an agent which ships the contents of local logs to a private Loki instance or [Grafana Cloud](https://grafana.com/oss/loki). It is usually deployed to every machine that has applications needed to be monitored.

This pack deploys Promtail as a Nomad [System Job](https://www.nomadproject.io/docs/schedulers#system) using the `grafana/promtail` Docker image and Consul Service named "promtail".

## Dependencies

This pack requires Linux clients to run properly.

## Configuration

This pack allows passing a pre-made Promtail configuration file by setting the `config_file` variable to a filepath relative to the directory the `nomad-pack` command is being called from. If the custom config file being used will require the promtail container to rune as a privileged container, you must set the `privileged_container` variable to `true`.

If no custom configuration file is provided, a default template will be used which is configured to scrape systemd-journal logs by default. You will need to set the `client_urls` variable with a list of URL's in order for promtail to ship the logs. **Using the default configuration sets the container to be run as privileged**.

## Container Privilege

This container runs the Promtail task as a ***Privileged*** container.

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_job_name"></a> [job\_name](#input\_job\_name) | The name to use as the job name which overrides using the pack name. | `string` | `""` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace where the job should be placed. | `string` | `"default"` | no |
| <a name="input_datacenters"></a> [datacenters](#input\_datacenters) | A list of datacenters in the region which are eligible for task placement. | `list(string)` | <pre>[<br>  "dc1"<br>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | The region where the job should be placed. | `string` | `"global"` | no |
| <a name="input_version_tag"></a> [version\_tag](#input\_version\_tag) | The docker image version. For options, see https://hub.docker.com/grafana/promtail | `string` | `"latest"` | no |
| <a name="input_privileged"></a> [privileged](#input\_privileged) | Controls whether the container will be run as a privileged container | `bool` | `false` | no |
| <a name="input_config_file"></a> [config\_file](#input\_config\_file) | Path to custom Promtail configuration file. | `string` | `""` | no |
| <a name="input_client_urls"></a> [client\_urls](#input\_client\_urls) | A list of client url's for promtail to send it's data to. | `list(string)` | `[]` | no |
| <a name="input_journal_max_age"></a> [journal\_max\_age](#input\_journal\_max\_age) | Maximum age of journald entries to scrape. | `string` | `"12h"` | no |
| <a name="input_constraints"></a> [constraints](#input\_constraints) | Constraints to apply to the entire job. | <pre>list(object({<br>    attribute = string<br>    operator  = string<br>    value     = string<br>  }))</pre> | <pre>[<br>  {<br>    "attribute": "${attr.kernel.name}",<br>    "operator": "",<br>    "value": "linux"<br>  }<br>]</pre> | no |
| <a name="input_promtail_group_network"></a> [promtail\_group\_network](#input\_promtail\_group\_network) | The Promtail network configuration options. | <pre>object({<br>    mode  = string<br>    ports = map(number)<br>  })</pre> | <pre>{<br>  "mode": "bridge",<br>  "ports": {<br>    "http": 9090<br>  }<br>}</pre> | no |
| <a name="input_promtail_group_services"></a> [promtail\_group\_services](#input\_promtail\_group\_services) | Configuration options of the promtail services and checks. | <pre>list(object({<br>    service_port_label = string<br>    service_name       = string<br>    service_tags       = list(string)<br>    check_enabled      = bool<br>    check_path         = string<br>    check_interval     = string<br>    check_timeout      = string<br>    upstreams = list(object({<br>      name = string<br>      port = number<br>    }))<br>  }))</pre> | <pre>[<br>  {<br>    "check_enabled": true,<br>    "check_interval": "3s",<br>    "check_path": "/ready",<br>    "check_timeout": "1s",<br>    "service_name": "promtail",<br>    "service_port_label": "http",<br>    "service_tags": [],<br>    "upstreams": []<br>  }<br>]</pre> | no |
| <a name="input_resources"></a> [resources](#input\_resources) | The resource to assign to the promtail service task. | <pre>object({<br>    cpu    = number<br>    memory = number<br>  })</pre> | <pre>{<br>  "cpu": 200,<br>  "memory": 256<br>}</pre> | no |
| <a name="input_container_args"></a> [container\_args](#input\_container\_args) | Arguments passed to the Promtail docker container | `list(string)` | <pre>[<br>  "-config.file=/etc/promtail/promtail-config.yaml",<br>  "-log.level=info"<br>]</pre> | no |
| <a name="input_extra_mounts"></a> [extra\_mounts](#input\_extra\_mounts) | Additional mounts to create in the Promtail container | <pre>list(object({<br>    type     = string<br>    source   = string<br>    target   = string<br>    readonly = bool<br>    bind_options = list(object({<br>      name  = string<br>      value = string<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_default_mounts"></a> [default\_mounts](#input\_default\_mounts) | Mounts that are configured when using the default Promtail configuration | <pre>list(object({<br>    type     = string<br>    source   = string<br>    target   = string<br>    readonly = bool<br>    bind_options = list(object({<br>      name  = string<br>      value = string<br>    }))<br>  }))</pre> | <pre>[<br>  {<br>    "bind_options": [<br>      {<br>        "name": "propagation",<br>        "value": "rshared"<br>      }<br>    ],<br>    "readonly": true,<br>    "source": "/var/log/journal",<br>    "target": "/var/log/journal",<br>    "type": "bind"<br>  },<br>  {<br>    "bind_options": [<br>      {<br>        "name": "propagation",<br>        "value": "rshared"<br>      }<br>    ],<br>    "readonly": false,<br>    "source": "/etc/machine-id",<br>    "target": "/etc/machine-id",<br>    "type": "bind"<br>  }<br>]</pre> | no |

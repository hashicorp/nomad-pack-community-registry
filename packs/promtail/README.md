# Promtail

[Promtail](https://grafana.com/docs/loki/latest/clients/promtail/) is an agent which ships the contents of local logs to a private Loki instance or [Grafana Cloud](https://grafana.com/oss/loki). It is usually deployed to every machine that has applications needed to be monitored.

This pack deploys Promtail as a Nomad [System Job](https://www.nomadproject.io/docs/schedulers#system) using the `grafana/promtail` Docker image and Consul Service named "promtail".

## Dependencies

This pack requires Linux clients to run properly.


## Configuration

This pack allows passing a pre-made Promtail configuration file by setting the `config_file` variable to a filepath relative to the directory the `nomad-pack` command is being called from. If the custom config file being used will require the promtail container to rune as a privileged container, you must set the `privileged_container` variable to `true`.

If no custom configuration file is provided, a default template will be used which is configured to scrape systemd-journal logs by default. You will need to set the `client_urls` variable with a list of URL's in order for promtail to ship the logs. **Using the default configuration sets the container to be run as privileged**.

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_job_name"></a> [job\_name](#input\_job\_name) | The name to use as the job name which overrides using the pack name. | `string` | `""` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name used to register the Consul Service | `string` | `"promtail"` | no |
| <a name="input_service_check_name"></a> [service\_check\_name](#input\_service\_check\_name) | Name of the service check registered with the Consul Service | `string` | `"Readiness"` | no |
| <a name="input_datacenters"></a> [datacenters](#input\_datacenters) | A list of datacenters in the region which are eligible for task placement. | `list(string)` | <pre>[<br>  "dc1"<br>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | The region where the job should be placed. | `string` | `"global"` | no |
| <a name="input_version_tag"></a> [version\_tag](#input\_version\_tag) | The docker image version. For options, see https://hub.docker.com/grafana/promtail | `string` | `"latest"` | no |
| <a name="input_http_port"></a> [http\_port](#input\_http\_port) | The Nomad client port that routes to the Promtail. | `number` | `9080` | no |
| <a name="input_resources"></a> [resources](#input\_resources) | The resource to assign to the promtail service task. | <pre>object({<br>    cpu    = number<br>    memory = number<br>  })</pre> | <pre>{<br>  "cpu": 200,<br>  "memory": 256<br>}</pre> | no |
| <a name="input_config_file"></a> [config\_file](#input\_config\_file) | Path to custom Promtail configuration file. | `string` | `""` | no |
| <a name="input_mount_journal"></a> [mount\_journal](#input\_mount\_journal) | Controls whether /var/log/journal is mounted in the container. If true, container will be run privileged. | `bool` | `true` | no |
| <a name="input_mount_machine_id"></a> [mount\_machine\_id](#input\_mount\_machine\_id) | Controls whether /etc/machine-id is mounted in the container. If true, container will be run privileged. | `bool` | `true` | no |
| <a name="input_privileged_container"></a> [privileged\_container](#input\_privileged\_container) | Run as a privileged container. Setting mount\_journal or mount\_machine\_id to true will override this. | `bool` | `false` | no |
| <a name="input_client_urls"></a> [client\_urls](#input\_client\_urls) | A list of client url's for promtail to send it's data to. | `list(string)` | `[]` | no |
| <a name="input_journal_max_age"></a> [journal\_max\_age](#input\_journal\_max\_age) | Maximum age of journald entries to scrape. | `string` | `"12h"` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | Promtail log level configuration. | `string` | `"info"` | no |
| <a name="input_upstreams"></a> [upstreams](#input\_upstreams) | Define Connect Upstreams used by Promtail. | <pre>list(object({<br>    name = string<br>    port = number<br>  }))</pre> | `[]` | no |

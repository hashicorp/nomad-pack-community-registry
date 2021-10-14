# Nomad Autoscaler

This pack deploys the Nomad Autoscaler application to Nomad as a single service job. It can be
deployed via the [Docker][docker_driver] or [exec][exec_driver] drivers.

## Variables

- `job_name` (string "") - The name to use as the job name which overrides using the pack name.
- `datacenters` (list(string) ["dc1"]) - A list of datacenters in the region which are eligible for 
task placement.
- `region` (string "global") - The region where the job should be placed.
- `namespace` (string "default") - The namespace where the job should be placed.
- `autoscaler_agent_network` (object) - The Nomad Autoscaler network configuration options.
  * `autoscaler_http_port_label` (string "http") - The label name to use for the Nomad Autoscaler
HTTP API.
- `autoscaler_agent_task` (object) - Details configuration options for the Nomad Autoscaler agent task.
  * `driver` (string "docker") - The Nomad driver to use when running the task. Supports `docker` and `exec`.
  * `version` (string "0.3.3") - The Nomad Autoscaler version to deploy.
  * `additional_cli_args` (list(string) []) - A list of CLI arguments that will be passed to the
Nomad Autoscaler. These will be appended to an initial list containing ["agent"].
  * `config_files` (list(string) []) - A list of config files to pass to the Nomad Autoscaler. If
included, the argument will automatically to appended to `base_args` and passed to the autoscaler.
  * `scaling_policy_files` (list(string) []) - A list of paths to scaling policies which will be passed
to the Nomad Autoscaler. If included, the argument will automatically to appended to `base_args` and
passed to the autoscaler.
- `autoscaler_agent_task_resources` (object) - The resource to assign to the Nomad Autoscaler task.
  * `cpu` (number 500) - Specifies the CPU required to run this task in MHz.
  * `memory` (number 256) - Specifies the memory required in MB.
- `autoscaler_agent_task_service` (object) - Configuration options of the Nomad Autoscaler service and check.
  * `enabled` (bool true) - Whether the service and check should be configured.
  * `service_name` (string "nomad-autoscaler") - Specifies the name this service will be advertised
as in Consul.
  * `service_tags` (list(string) []) - Specifies the list of tags to associate with the Nomad
Autoscaler service.
  * `check_interval` (string "3s") - Specifies the frequency of the health checks that Consul will perform.
  * `check_timeout` (string "1s") - Specifies how long Consul will wait for a health check query to succeed.

[docker_driver]: (https://www.nomadproject.io/docs/drivers/docker)
[exec_driver]: (https://www.nomadproject.io/docs/drivers/exec)

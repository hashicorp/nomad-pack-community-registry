# Drone

This pack can be used to run [Drone][drone] server and Drone agent on your Nomad cluster. It currently supports being run by the [Docker][docker_driver], and is configured by environment variables.

## Variables

| Variable              | Type (default)                      | Explanation                                                                |
|-----------------------|-------------------------------------|----------------------------------------------------------------------------|
| job_name              | string ("")                         | The name to use as the job name which overrides using the pack name.       |
| datacenters           | list(string) (["dc1"])              | A list of datacenters in the region which are eligible for task placement. |
| region                | string ("global")                   | The region where the job should be placed.                                 |
| namespace             | string ("default")                  | The namespace where the job should be placed.                              |
| constraints           | list(object))                       | Constraints to apply to the entire job.                                    |
| group_network         | object                              | The Drone network configuration options.                                   |
| drone_server_cfg      | string                              | The Drone server config                                                    |
| drone_server_image    | string ("drone/drone")              | The Drone server image                                                     |
| drone_server_version  | string ("2.1.0")                    | The Drone server version                                                   |
| drone_agent_cfg       | string                              | The Drone agent config                                                     |
| drone_agent_image     | string ("drone/drone-runner-nomad") | The Drone agent image                                                      |
| drone_agent_version   | string ("latest")                   | The Drone agent version                                                    |
| server_task_resources | object                              | The resource to assign to the server task.                                 |
| agent_task_resources  | object                              | The resource to assign to the agent task.                                  |
| task_services         | object                              | Configuration options of the Prometheus services and checks.               |

[docker_driver]: (https://www.nomadproject.io/docs/drivers/docker)

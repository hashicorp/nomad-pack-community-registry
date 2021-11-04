# Drone

This pack can be used to run [Drone][https://drone.io] server and Drone agent on your Nomad cluster. It currently supports being run by the [Docker][https://www.nomadproject.io/docs/drivers/docker], and is configured by environment variables.

In order to launch Drone, you must provide credentials to your Source Control Management provider of choice. Click on the version control
system you want to use, such as GitHub, GitLab, or Bitbucket, in the [Drone Documentation](https://readme.drone.io/server/overview/) for
more information on which environment variables to provide. These environment variables should be set in `drone_server_cfg` and `drone_agent_cfg`.

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

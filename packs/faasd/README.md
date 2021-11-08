# faasd

This pack contains all you need to deploy faasd (version 2 by default) in Nomad. It uses Docker driver.


## Variables

- `job_name` (string) - The name to use as the job name which overrides using the pack name.
- `region` (string) - The region where jobs will be deployed.
- `datacenters` (list of strings) - A list of datacenters in the region which are eligible for task placement.
- `namespace` (string) - The namespace where the job should be placed.
- `constraints` (string) - Constraints to apply to the entire job.
- `nats_image_name` (string) - The Nats docker image name
- `auth_plugin_image_name` (string) - The Authentication docker image name
- `gateway_image_name` (string) - The Gateway docker image name
- `queue_worker_image_name` (string) - The Queue Worker docker image name
- `faasd_version` (string) - The Faasd version number
- `nats_image_tag` (string) - The Nats docker image tag
- `auth_plugin_image_tag` (string) - The Authentication docker image tag
- `gateway_image_tag` (string) - The Gateway docker image tag
- `queue_worker_image_tag` (string) - The Queue Worker docker image tag
- `faasd_provider_task_resources` (object, number number) - Resources used by Faasd task
- `nats_task_resources` (object, number number) - Resources used by Nats task
- `basic_auth_task_resources` (object, number number) - Resources used by Authentication task
- `gateway_task_resources` (object, number number) - Resources used by Gateway task
- `queue_worker_task_resources` (object, number number) - Resources used by Queue Worker task
- `register_auth_consul_service` (bool) - If you want to register a consul service for the Authentication task
- `register_nats_consul_service` (bool) - If you want to register a consul service for the Nats task
- `register_gateway_consul_service` (bool) - If you want to register a consul service for the Gateway task
- `register_provider_consul_service` bool() - If you want to register a consul service for the Faasd provider task
- `auth_consul_service_name` (string) - The consul service name for the Authentication task 
- `provider_consul_service_name` (string) - The consul service name for the Faasd provider task
- `nats_consul_service_name` (string) - The consul service name for the Nats task
- `gateway_consul_service_name` (string) - The consul service name for the Gateway task
- `consul_service_tags` (list of strings) - The consul service name for the Faasd application
- `dns_servers` (list of strings) - To add custom dns servers
- `basic_auth_user` (string) - The authentication username
- `basic_auth_password` (string) - The authentication password
- `docker_faasd_env_vars` (map of strings) - Environment variables to pass to Docker container

## faasd Environment Variables

You can pass the right environment variables to faasd.
An example of the `docker_faasd_env_vars` to use is in the `vars.nomad` file.

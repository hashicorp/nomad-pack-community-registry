# Nginx

This pack contains a single system job that runs Nginx across all Nomad clients.

See the [Load Balancing with Nginx](https://developer.hashicorp.com/nomad/tutorials/load-balancing/load-balancing-nginx) tutorial for more information.

## Dependencies

This pack requires Linux clients to run.

## Variables

- `http_port` (number) - The Nomad client port that routes to the Nginx. This port will be where you visit your load balanced application
- `service_name` (string) - The consul service you wish to load balance
- `version_tag` (string) - The docker image version. For options, see https://hub.docker.com/_/nginx
- `resources` (object) - The resource to assign to the Nginx system task that runs on every client
- `job_name` (string) - The name to use as the job name which overrides using the pack name
- `datacenters` (list of string) - A list of datacenters in the region which are eligible for task placement
- `region` (string) - The region where the job should be placed

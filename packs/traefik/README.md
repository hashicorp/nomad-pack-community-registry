# Traefik

This pack contains a single system job that runs Traefik across all Nomad clients.

See the [Load Balancing with Traefik](https://learn.hashicorp.com/tutorials/nomad/load-balancing-traefik) tutorial for more information.

## Dependencies

This pack requires Linux clients to run.

## Variables

- `http_port` (number) - The Nomad client port that routes to the Traefik. This port will be where you visit your load balanced application
- `api_port` (number) - The port assigned to visit the Traefik API
- `consul_port` (number) - The consul HTTP port
- `version_tag` (string) - The docker image version
- `resources` (object) - The resource to assign to the Traefik system task that runs on every client
- `job_name` (string) - The name to use as the job name which overrides using the pack name
- `datacenters` (list of string) - A list of datacenters in the region which are eligible for task placement
- `region` (string) - The region where the job should be placed

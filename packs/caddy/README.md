# Caddy

This pack contains a single system job that runs [Caddy](https://caddyserver.com/v2) across all Nomad clients.

## Dependencies

This pack requires Linux clients to run.

## Variables

- `job_name` (string) - The name to use as the job name which overrides using the pack name.
- `datacenters` (list of string) - A list of datacenters in the region which are eligible for task placement.
- `region` (string) - The region where the job should be placed.
- `namespace` (string "default") - The namespace where the job should be placed.
- `http_port` (number) - The Nomad client port that routes HTTP traffic to Caddy.
- `https_port` (number) - The Nomad client port that routes HTTPS traffic to Caddy.
- `version_tag` (string) - The docker image version. For options, see [Dockerhub](https://hub.docker.com/_/caddy).
- `resources` (object) - The resource to assign to the Caddy system task that runs on every client.

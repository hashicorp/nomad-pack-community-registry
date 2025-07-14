# Caddy

This pack contains a single system job that runs [Caddy](https://caddyserver.com/) across all Nomad clients.

## Variables

- `job_name` (string) - The name to use as the job name which overrides using the pack name.
- `datacenters` (list of string) - A list of datacenters in the region which are eligible for task placement.
- `region` (string) - The region where the job should be placed.
- `namespace` (string "default") - The namespace where the job should be placed.
- `constraints` (list(object)) - Constraints to apply to the entire job.
- `version_tag` (string) - The docker image version. For options, see [Dockerhub](https://hub.docker.com/_/caddy).
- `admin_port` (number) - The HTTP port for Caddy administration API.
- `http_port` (number) - The Nomad client port that routes HTTP traffic to Caddy.
- `https_port` (number) - The Nomad client port that routes HTTPS traffic to Caddy.
- `http_healthcheck_path` (string) - The HTTP path served by Caddy to call for health checks.
- `https_healthcheck_path` (string) - The HTTPS path served by Caddy to call for health checks.
- `resources` (object) - The resource to assign to the Caddy system task that runs on every client.
- `caddyfile` (string) - The Caddyfile configuration to pass to the task.

### `constraints` List of Objects

[Nomad job specification constraints][job_constraint] allows restricting the set of eligible nodes
on which the Caddy task will run.

Caddy does not require any constraints by default.

### `resources` Object

-`cpu` (number 500) - Specifies the CPU required to run this task in MHz.
-`memory` (number 256) - Specifies the memory required in MB.

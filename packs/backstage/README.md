# backstage

This pack contains a service job that runs [Backstage](https://backstage.io/) in a single Nomad client. It currently supports
being run by the [Docker](https://www.nomadproject.io/docs/drivers/docker) driver.

It has 2 tasks:
- **Backstage:** [*(reference)*](https://backstage.io) the open platform for building developer portals;
- **PostgreSQL:** [*(reference)*](https://www.postgresql.org/) the persistent database used by Backstage.

Setup:
- Service-to-service communication is handled by Nomad;
- PostgreSQL's state is persisted with Nomad Host Volumes.

## Requirements
Clients that expect to run this job require:
- Nomad >= 1.4.0 (because the pack use [Nomad Variables](https://developer.hashicorp.com/nomad/docs/concepts/variables))
- [Docker volumes](https://www.nomadproject.io/docs/drivers/docker "Docker volumes") to be enabled within their Docker plugin stanza, due to the usage of Nomad's host volume:
```hcl
plugin "docker" {
  config {
    volumes {
      enabled = true
    }
  }
}
```

- [Host volume](https://www.nomadproject.io/docs/configuration/client#host_volume-stanza "Host volume") to be enabled in the client configuration (the host volume directory - /var/lib/postgres - must be created in advance):
```hcl
client {
  host_volume "backstage-postgres" {
    path      = "/var/lib/postgres"
    read_only = false
  }
}
```

## Customizing the Docker images

The 2 docker images can be replaced by using their variable names:
- postgres_task_image
- backstage_task_image

Example:
```bash
$ nomad-pack run backstage --var backstage_task_image="ghcr.io/backstage/backstage:1.7.1"
```

## Pack Usage

<!-- Include information about how to use your pack -->

### Prerequisite

Create an variable specification file:
```hcl
# spec.nv.hcl
path = "nomad/jobs"

items {
  # Mandatory variables
  postgres_user = "your_postgres_username"
  postgres_password = "your_postgres_password"

  #Optional variables
  github_token = "your_github_token"
}
```

The default docker image for Backstage is configured to use GitHub in order to locate entities (see [GitHub integration](https://backstage.io/docs/integrations/github/locations)), so you will need to define a variable to store your GitHub token. 

If you use an other integration in your custom image, Azure DevOps for instance, you will need to define a variable for it (e.g. ```azure_token = "your_ado_token"```).

To set your variables in your Nomad instance, execute the following command:

```bash
$ nomad var put @spec.nv.hcl
```

## Variables

<!-- Include information on the variables from your pack -->

- `job_name` (string) - The name to use as the job name which overrides using
  the pack name
- `datacenters` (list of strings) - A list of datacenters in the region which
  are eligible for task placement
- `region` (string) - The region where jobs will be deployed
- `postgresql_group_nomad_service_name` (string) - The nomad service name for the PostgreSQL application
- `postgresql_task_image` (string) - PostgreSQL's Docker image (must include the tag)
- `postgresql_task_volume_path` (string) - The volume's absolute path in the host to be used by PostgreSQL
- `postgresql_task_resources` (object, number number) - The resources to assign to the PostgreSQL service
- `backstage_group_nomad_service_name` (string) - The nomad service name for the Backstage application
- `backstage_task_image` (string) - Backstage's Docker image (must include the tag)
- `backstage_task_nomad_vars` (map of string) - Backstage's nomad variables (see below for the details)
- `backstage_task_resources` (object, number number) - The resources to assign to the Backstage service

### Custom Nomad Variables
If you need to use other Nomad variables than `postgres_user` and `postgres_password` with this pack, you will need to pass them to `backstage_task_nomad_vars`.

```hcl
backstage_task_nomad_vars = [
  {
    key = "AZURE_TOKEN"
    value = "azure_token"
  },
  {
    key = "YOUR_SECRET_ENV_VAR"
    value = "your_nomad_var_key"
  }
]
```

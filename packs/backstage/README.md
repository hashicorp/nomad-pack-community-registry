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
```
nomad-pack run backstage --var backstage_task_image="ghcr.io/backstage/backstage:1.7.1"
```

## Pack Usage

<!-- Include information about how to use your pack -->

### Changing the Message

To change the message this server responds with, change the "message" variable
when running the pack.

```
nomad-pack run backstage --var message="Hola Mundo!"
```

This tells Nomad Pack to tweak the `MESSAGE` environment variable that the
service reads from.

### Consul Service and Load Balancer Integration

Optionally, it can configure a Consul service.

If the `register_consul_service` is unset or set to true, the Consul service
will be registered.

Several load balancers in the the [Nomad Pack Community Registry][pack-registry]
are configured to connect to this service by default.

The [NGINX][pack-nginx] and [HAProxy][pack-haproxy] packs are configured to
balance the Consul service `backstage-service`, which is the default value
for the `consul_service_name` variable.

The [Fabio][pack-fabio] and [Traefik][pack-traefik] packs are configured to
search for Consul services with the tags found in the default value of the
`consul_service_tags` variable.



## Variables

<!-- Include information on the variables from your pack -->

- `message` (string) - The message your application will respond with
- `count` (number) - The number of app instances to deploy
- `job_name` (string) - The name to use as the job name which overrides using
  the pack name
- `datacenters` (list of strings) - A list of datacenters in the region which
  are eligible for task placement
- `region` (string) - The region where jobs will be deployed
- `register_consul_service` (bool) - If you want to register a consul service
  for the job
- `consul_service_tags` (list of string) - The consul service name for the
  backstage application
- `consul_service_name` (string) - The consul service name for the backstage
  application

[pack-registry]: https://github.com/hashicorp/nomad-pack-community-registry
[pack-nginx]: https://github.com/hashicorp/nomad-pack-community-registry/tree/main/packs/nginx/README.md
[pack-haproxy]: https://github.com/hashicorp/nomad-pack-community-registry/tree/main/packs/haproxy/README.md
[pack-fabio]: https://github.com/hashicorp/nomad-pack-community-registry/tree/main/packs/fabio/README.md
[pack-traefik]: https://github.com/hashicorp/nomad-pack-community-registry/tree/main/packs/traefik/traefik/README.md

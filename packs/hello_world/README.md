# Hello World Service

This pack is a simple Nomad job that runs as a service and can be accessed via HTTP.

## Changing the Message

To change the message this server responds with, change the "message" variable when running the pack.

```
nomad-pack run hello_world --var message="Hola Mundo!"
```

This tells Nomad Pack to tweak the `MESSAGE` environment variable that the service reads from.

## Consul Service and Load Balancer Integration

Optionally, it can configure a Consul service.

If the `register_consul_service` is unset or set to true, the Consul service will be registered.

Several load balancers in the [Nomad Pack Community Registry](../../README.md) are configured to connect to this service by default.

The [nginx](../nginx/README.md) and [HAProxy](../haproxy/README.md) packs are configured to balance the Consul service "hello-world-service", which is th default value for the "consul_service_name" variable.

The [Fabio](../fabio/README.md) and [Traefik](../traefik/README.md) packs are configured to search for Consul services with the tags found in the default value of the "consul_service_tags" variable.

## Variables

- `message` (string) - The message your application will respond with
- `count` (number) - The number of app instances to deploy
- `job_name` (string) - The name to use as the job name which overrides using the pack name
- `datacenters` (list of strings) - A list of datacenters in the region which are eligible for task placement
- `region` (string) - The region where jobs will be deployed
- `register_consul_service` (bool) - If you want to register a consul service for the job
- `consul_service_tags` (list of string) - The consul service name for the hello-world application
- `consul_service_name` (string) - The consul service name for the hello-world application

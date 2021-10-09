# Hello World Service

This pack is a simple Nomad job that runs as a service and can be accessed via HTTP.

## Changing the Message

To change the message this server responds with, change the "message" variable when running the pack.

```
nomad-pack run hello_world --var message="Hola Mundo"
```

## Consul Service and Load Balancer Integration

Optionally, it can configure a Consul service.

If the `register_consul_service` is unset or set to true, the Consul service will be registered.

Several load balancers in the [The Nomad Pack Community Registry](../README.md) are configured to connect to this service by default.

The [NginX](../nginx/README.md) and [HAProxy](../haproxy/README.md) packs are configured to balance the Consul service "hello-world-service", which is th default value for the "consul_service_name" variable.

The [Fabio](../fabio/README.md) and [Traefik](../traefik/README.md) packs are configured to search for Consul services with the tags found in the default value of the "consul_service_tags" variable.

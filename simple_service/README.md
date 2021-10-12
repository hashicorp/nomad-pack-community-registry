# Simple Service

This pack is a used to deploy a Docker image to as a service job to Nomad.

This is ideal for configuring and deploying a simple web application to Nomad.

## Customizing Resources

<!-- TODO -->

## Customizing Ports

<!-- TODO -->

## Customizing Environment Variables

<!-- TODO -->

## Customizing Consul and Upstream Services

<!-- TODO -->

## Consul Service and Load Balancer Integration

Optionally, this pack can configure a Consul service.

If the `register_consul_service` is unset or set to true, the Consul service will be registered.

Several load balancers in the [The Nomad Pack Community Registry](../README.md) are configured to connect to
this service with ease.

The [NginX](../nginx/README.md) and [HAProxy](../haproxy/README.md) packs can be configured to balance over the
Consul service deployed by this pack. Just ensure that the "consul_service_name" variable provided to those
packs matches this consul_service_name.

The [Fabio](../fabio/README.md) and [Traefik](../traefik/README.md) packs are configured to search for Consul
services with the specific tags.

To tag this Consul service to work with Fabio, add "urlprefix-<PATH>"
to the consul_tags. For instance, to route at the root path, you would add "urlprefix-/". To route at the path "/api/v1", you would add '"urlprefix-/api/v1".

To tag this Consul service to work with Traefik, add "traefik.enable=true" to the consul_tags, also add "traefik.http.routers.http.rule=Path(`<PATH>`)". To route at the root path, you would add "traefik.http.routers.http.rule=Path(`/`)". To route at the path "/api/v1", you would add "traefik.http.routers.http.rule=Path(`/api/v1`)".

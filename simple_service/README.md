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
services with the specific tags. To automatically tag this Consul service to work with Fabio, set the
"use_fabio_tags" variable to true. To automatically tag this Consul service to work with Traefik, set the
"use_traefik_tags" variable to true. For either load balancer, you can set "load_balancer_path" to only
route to this client when the load_balancer request is at a certain path, for instance "/api".

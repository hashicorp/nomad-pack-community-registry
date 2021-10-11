# Grafana

[Grafana](https://grafana.com/oss/loki/) is a multi-platform open source analytics and interactive visualization web application. It provides charts, graphs, and alerts for the web when connected to supported data sources.

This pack deploys a single instance of the Grafana docker image `grafana/grafana` and a Consul Service named "grafana". This Consul Service can be connected to other upstream Consul services deployed using Nomad. These other services are defined using the `upstreams` variable.

## Dependencies

This pack requires Linux clients to run properly.

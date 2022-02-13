# Grafana

[Grafana](https://grafana.com/oss/loki/) is a multi-platform open source analytics and interactive visualization web application. It provides charts, graphs, and alerts for the web when connected to supported data sources.

This pack deploys a single instance of the Grafana docker image `grafana/grafana` and a Consul Service named "grafana". This Consul Service can be connected to other upstream Consul services deployed using Nomad. These other services are defined using the `upstreams` variable.

## Variables

- `job_name` (string "") - The name to use as the job name which overrides using the pack name.
- `datacenters` (list(string) ["dc1"]) - A list of datacenters in the region which are eligible for
  task placement.
- `region` (string "global") - The region where the job should be placed.
- `dns` (object) - Network DNS configuration
- `grafana_version_tag` (string "latest" ) - The version of Grafana Image
- `grafana_http_port` (number "3000" ) - The Grafana Port for http
- `grafana_upstreams` (list(object)) - Upstream configuration for sidecar proxy
- `grafana_resources` (object) - CPU and Memory configuration for Grafana
- `grafana_consul_tags` (list(string)) - Service tag definition for Consul
- `grafana_volume` (object) - Persistent Volume configuration for Grafana
- `grafana_env_vars` (list(object)) - Environment Variables for Grafana
- `grafana_task_artifacts` (list(object)) - Nomad Artifacts for Grafana
- `grafana_task_config_dashboards` (string) - Yaml configuration for automatic provision of dashboards
- `grafana_task_config_datasources` (string) - Yaml configuration for automatic provision of datasources
- `grafana_task_config_plugins` (string) - yaml configuration for automatic provision of plugins

## Dependencies

This pack requires Linux clients to run properly.

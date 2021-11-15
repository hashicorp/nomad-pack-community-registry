# OpenTelemetry Collector

This pack containers a single system job that runs an OpenTelemetry Collector
across all Nomad clients.

See the [OpenTelemetry Collector](https://opentelemetry.io/docs/collector/) docs
for more information.

## Dependencies

This pack requires Linux clients to run.

## Variables

- `consul_service_name` (string) - The consul service you wish to load balance
- `container_registry` (string) - The docker registry to pull the image from.
- `container_image_name` (string) - The name of the image to pull.
- `job_name` (string) - The name to use as the job name which overrides using the pack name
- `datacenters` (list of string) - A list of datacenters in the region which are eligible for task placement
- `region` (string) - The region where the job should be placed
- `resources` (object) - The resource to assign to the OpenTelemetry Collector system task that runs on every client
- `container_version_tag` (string) - The docker image version. For options, see https://hub.docker.com/r/otel/opentelemetry-collector
- `network_ports` (list of object) - A list of maps describing the ports in the network stanza
- `config_yaml` (string) - The YAML config for the collector.

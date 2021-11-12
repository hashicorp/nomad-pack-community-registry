# OpenTelemetry Collector

This pack containers a single system job that runs an OpenTelemetry Collector
across all Nomad clients.

See the [OpenTelemetry Collector](https://opentelemetry.io/docs/collector/) docs
for more information.

## Dependencies

This pack requires Linux clients to run.

## Variables

- `datacenters` (list of string) - A list of datacenters in the region which are eligible for task placement
- `region` (string) - The region where the job should be placed
- `container_image_name` (string) - The name of the image to pull.
- `config_yaml_path` (string) - The YAML config for the collector.
- `job_name` (string) - The name to use as the job name which overrides using the pack name
- `consul_service_name` (string) - The consul service you wish to load balance
- `container_registry` (string) - The docker registry to pull the image from.
- `container_version_tag` (string) - The docker image version. For options, see https://hub.docker.com/r/otel/opentelemetry-collector
- `resources` (object) - The resource to assign to the OpenTelemetry Collector system task that runs on every client

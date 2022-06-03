# OpenTelemetry Collector

This pack can be used to run the [OpenTelemetry Collector][collector] on your Nomad cluster.

It currently supports being run by the [Docker][docker_driver] driver and allows for the Collector to be configured in
different ways.

## Variables

- `job_name` (`string` `""`) - The name to use as the job name which overrides using the pack name.
- `datacenters` (`list(string)` `["dc1"]`) - A list of datacenters in the region which are eligible for task placement.
- `region` (`string` `"global"`) - The region where the job should be placed.
- `namespace` (`string` `"default"`) - The namespace where the job should be placed.
- `constraints` (`list(object)` `[]`) - Constraints to apply to the entire job.
- `job_type` (`string` `"system"`) - The scheduler type to use for the job.
- `instance_count` (`number` `"1"`) - In case the job is ran as a service, how many copies of the OpenTelemetry
  Collector group to run.
- `privileged_mode` (`bool` `"true"`) - Determines if the OpenTelemetry Collector should run with privleged access to
  the host. Useful when using the [hostmetrics][hostmetricsreceiver] receiver. See `examples/privileged.hcl` for a an
  example.
- `task_config` (`object`) - The OpenTelemetry Collector task config options.
- `vault_config` (`object`) - The OpenTelemetry Collector job's Vault configuration. Set `enabled = true` to configure
  the job's [Vault integration][vault_integration].
- `traefik_config` (`object`) - Traefik service configurations for the OpenTelemetry Collector. Includes support for
  HTTP and gRPC. See [`examples/traefik.hcl`](examples/traefik.hcl) for an example (NOTE: Also deploy with Traefik
  sample jobspec, [`examples/sample_traefik_spec.nomad`](examples/sample_traefik_spec.nomad)).
- `network_config` (`object`) - The OpenTelemetry Collector job's network configuration options.
- `resources` (`object`) - The resources to assign to the OpenTelemetry Collector task.
- `config_yaml_location` (`string` `"local/otel/config.yaml"`) - The location of `otel-collector-config.yaml` in the
  OTel Collector container instance.
- `config_yaml` (`string`) - The Collector configuration to pass the task. The default value configures an example
  selection of receivers, processors, extensions, and exporters. You will likely need to customize this in order to
  have a properly configured target for your telemetry data.
- `additional_templates` - (`list(object)`) - Additional job templates to render in the task; access Consul KV, or the
  Vault KV or secrets engine. `data` and `destination` are required.
- `task_services` (`list(object)`) - Configuration options of the OpenTelemetry Collector services and checks.

### `constraints` List of Objects

[Nomad job specification constraints][job_constraint] allows restricting the set of eligible nodes on which the
OpenTelemetry Collector task will run.

- `attribute` (`string`) - Specifies the name or reference of the attribute to examine for the constraint.
- `operator` (`string`) - Specifies the comparison operator. The ordering is compared lexically.
- `value` (`string`) - Specifies the value to compare the attribute against using the specified operation.

The default value constrains the job to run on client whose kernel name is `linux`. The HCL variable list of objects is
shown below and uses a double dollar sign for escaping:

```hcl
[
  {
    attribute = "$${attr.kernel.name}",
    value     = "linux",
    operator  = "",
  }
]
```

### `network_config` Object

- `mode` (`string`) - Mode of the network.
- `ports` (`map<string|number>`) - Specifies the port mapping for the OpenTelemetry Collector task. The map key
  indicates the port label, and the value is the OpenTelemetry Collector port inside the network namespace.

The default value for this variable configures a bridge network with the following port map:

```hcl
{
  mode = "bridge"
  ports = {
    "otlp"               = 4317
    "otlphttp"           = 4318
    "metrics"            = 8888
    "zipkin"             = 9411
    "healthcheck"        = 13133
    "jaeger-grpc"        = 14250
    "jaeger-thrift-http" = 14268
    "zpages"             = 55679
  }
}
```

### `task_config` Object

- `image` (`string` `"otel/opentelemetry-collector-contrib"`) - The OpenTelemetry Collector container image to use.
- `version` (`string` `"latest"`) - The OpenTelemetry Collector version to run. Defaults to `latest` but it's
  recommended to set a specific [tag][otel_docker_tags].
- `env` (`map(string)`) - A map of environment variables to set in the OpenTelemery Collector's environment

### `resources` Object

- `cpu` (`number` `256`) - Specifies the CPU required to run this task in MHz.
- `memory` (`number` `512`) - Specifies the memory required in MB.

### `vault_config` Object

These all map directly to the values for the [Vault integration][vault_integration].

- `enabled` (`bool` `false`) - Enable the integration for the job.
- `policies` (`list(string)`) - The named list of Vault policies this job requires.
- `change_mode` (`string` `"restart"`) - The behaviour Nomad should take if the Vault token changes.
- `change_signal` (`string`) - The signal Nomad should send to the task. Used when `change_mode` is `signal`.
- `env` (`bool` `true`) - Specifies if `VAULT_TOKEN` and `VAULT_NAMESPACE` environment variables should be set when
  starting the task.
- `namespace` (`string`) - Specifies the Vault Namespace to use for the task. Requires Vault Enterprise.

### `traefik_config` Object

- `enabled` (`bool` `false`) - Enable Traefik configs for the OTel Collector. Also requires a Traefik job to be running
  in Nomad. An example on how to run Traefik the pack is provided in the [`Running the OTel Collector + Traefik
  Example`](#running-the-otel-collector--traefik-example) section below.
- `http_host` (`string` `"otel-collector-http.myhost.com"`) - The HTTP hostname to which Traefik will route OTLP HTTP
  requests.

> **NOTES:**
> 1. The default Traefik config does not have TLS enabled (both for HTTP and gRPC). For more on enabling TLS on Traefik
> with Nomad, check out [this post by David Alfonzo](https://storiesfromtheherd.com/traefik-in-nomad-using-consul-and-tls-5be0007794ee).
> 2. Since we don't have TLS enabled, it means that the gRPC `HostSNI` value must be set to a wildcard value (see [this
> discussion](https://community.traefik.io/t/configuration-of-non-http-port-without-tls/5901/2) for more info).
> 3. To test the Traefik configs, you can run a sample Go client/server program
> [here](https://github.com/avillela/go-otel-instrumentation), which contains both HTTP and gRPC examples.
> 4. For detailed documentation on running the OTel Collector on Nomad with Traefik, check out
> [this guide](https://adri-v.medium.com/4eaf009b8382?source=friends_link&sk=a1a0612a156d20e86549bd925d419bc3).

### `additional_templates` Object

Configure one or more additional templates to render. Each item of the list is rendered as its own
[`template` stanza][template_stanza].

This creates a convenient way to ship configuration files that are populated from environment variables, Consul data,
Vault secrets, or just general configurations within a Nomad task.

Only `data` and `destination` are required.

- `data` (`string`) - Specifies the raw template to execute.
- `destination` (`string`) - Specifies the location where the resulting template should be rendered.
- `change_mode` (`string` `"restart"`) - Specifies the behavior Nomad should take if the rendered template changes.
- `change_signal` (`string`) - Specifies the signal to send to the task if the template changes. Required if
  `change_mode` is `signal`.
- `env` (`bool` `false`) - Specifies the template should be read back in as environment variables for the task.
- `perms` (`string` `"644"`) - Specifies the rendered template's permissions. File permissions are given as octal of
  the Unix file permissions.

### `task_services` List of Objects

- `service_port_label` (`string`) - Specifies the port to advertise for this service.
- `service_name` (`string`) - Specifies the name this service will be advertised as in Consul.
- `service_tags` (`list(string)`) - Specifies the list of tags to associate with this service.
- `check_enabled` (`bool`) - Whether to enable a check for this service.
- `check_path` (`string`) - The HTTP path to query the health check should query.
- `check_interval` (`string`) - Specifies the frequency of the health checks that Consul will perform.
- `check_timeout` (`string`) - Specifies how long Consul will wait for a health check query to succeed.

The default value for this variable configures listeners for the following receivers: OTLP, OTLP HTTP, Jaeger GRPC,
Jaeger Thrift HTTP, and Zipkin. It also configures the Collector's Healthcheck and the zpages extension.

## Running the OTel Collector + Traefik Example

To run the OTel Collector + Traefik example, you'll need to run this pack and the Traefik pack as follows, assuming that you are starting from the repo root:

```bash
nomad-pack run traefik -f packs/opentelemetry_collector/examples/traefik_vars.hcl

nomad-pack run opentelemetry_collector -f packs/opentelemetry_collector/examples/with_traefik.hcl
```

[collector]: https://opentelemetry.io/docs/collector
[docker_driver]: https://www.nomadproject.io/docs/drivers/docker
[hostmetricsreceiver]: https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/receiver/hostmetricsreceiver#host-metrics-receiver
[job_constraint]: https://www.nomadproject.io/docs/job-specification/constraint
[otel_docker_tags]: https://hub.docker.com/r/otel/opentelemetry-collector-contrib/tags
[template_stanza]: https://www.nomadproject.io/docs/job-specification/template
[vault_integration]: https://www.nomadproject.io/docs/job-specification/vault

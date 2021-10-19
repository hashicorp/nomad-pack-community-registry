Terraform Cloud Agent
=====================

This pack deploys the
[Terraform Cloud Agent](https://www.terraform.io/docs/cloud/agents/index.html)
using the [official Docker container](https://hub.docker.com/r/hashicorp/tfc-agent).

Variables
=========

The following variables are settable when running this pack.

## Nomad-related variables

### Optional

* `datacenters` (`list(string)`, `["dc1"]`) - An array of Nomad datacenter names.
* `region` (`string`, `""`) - The region where the job should be placed.
* `namespace` (`string`, `""`) - Optional namespace to run the job in.
* `count` (`number`, `1`) - Number of agent processes to run.
* `resources` (`object`) - Resources required to run the task.
  * `cpu` (`number`, `2048`) - CPU MHz required to run the task.
  * `memory` (`number`, `2048`) - Memory in MB required to run the task.

## Terraform Cloud Agent variables

These variables may be set to change the behavior of the tfc-agent. Note that
empty/zero/false values are used as defaults for all options unless otherwise
noted to defer default configuration to the tfc-agent binary itself. See the
output of `docker run hashicorp/tfc-agent:<version> -h` for details.

### Required

* `agent_token` (`string`) - The authentication token the agent will
  use to register with Terraform Cloud. This value is required and has no
  default.

### Optional

* `tfc_address` (`string`) - The API address of the Terraform Cloud instance to
  register the agent(s) with. When empty, defaults to the public Terraform
  Cloud instance.
* `agent_version` (`string`, `"latest"`) - The version of the
  `hashicorp/tfc-agent` Docker container to run.
* `agent_name` (`string`) - Friendly name to assign to the registered agent.
* `agent_log_level` (`string`) - The level of log granularity to configure for
  the agent. Valid values are `trace`, `debug`, `info`, `warn`, and `error`.
* `agent_log_json` (`bool`) - When true, the logs emitted by the agent process
  will be JSON-formatted, and contain rich metadata. The default is
  text-formatted logs which are more easily consumed directly by humans.
* `agent_auto_update` (`string`) - The automatic update strategy to configure
  on the agent. When `disabled` is specified, the agent will not perform online
  upgrades while it is running. This is useful if you'd like to control the
  precise version of the agent to run. When `patch` is specified, the agent
  will automatically apply patches from the same minor version series.  When
  `minor` is specified, the agent will apply all minor version updates as they
  become available, within the same major version series.
* `agent_single` (`bool`) - When true, the agent will wait for and execute at
  most one job. This provides the highest level of isolation between agent job
  executions.
* `agent_otlp_address` (`string`) - OpenTelemetry gRPC endpoint for submitting
  agent metrics and tracing data.
* `agent_otlp_cert` (`string`) - Go-getter path to a TLS certificate for
  encrypting gRPC connections made by the OpenTelemetry client library.

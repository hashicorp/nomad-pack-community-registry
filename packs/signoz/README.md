# SigNoz on HashiCorp Nomad

Deploy the complete [SigNoz](https://signoz.io) observability stack on HashiCorp
Nomad. This pack includes ClickHouse, ZooKeeper, the SigNoz application, and the
OpenTelemetry Collector, all running as Docker containers via Nomad's [Docker
driver](https://www.nomadproject.io/docs/drivers/docker).

## Prerequisites

Ensure your environment has:

* A running Nomad cluster
* Consul enabled for service discovery
* Nomad variable store configured
* Host volumes set up for persistent storage

## Setup Guide

There's a `setup.sh` script in this Pack directory that can automatically
perform the required setup steps. Set the `RELEASE`, `NAMESPACE`, and
`CLICKHOUSE_PASSWORD` environment variables and it will make the appropriate
changes. If you want to perform each step manually, you can do the following:

### Step 1: Configure ClickHouse Password

Store your ClickHouse password securely using Nomad variables:

```hcl
# spec.nv.hcl
# Use path "nomad/jobs" to make it accessible to all jobs in the pack
path = "<your_release_name>"

items {
  clickhouse_password = "your_clickhouse_password"  # Change this
}
```

Load the variables:

```bash
nomad var put -namespace $NAMESPACE @spec.nv.hcl
```

### Step 2: Create Access Policy

Define a policy that grants tasks read access to your variables:

```hcl
# signoz-shared-vars.policy.hcl
namespace "<your-shared-namespace>" {
  variables {
    path "<your_release_name>" {
      capabilities = ["read"]
    }
  }
}
```

Apply the policy to each job that this pack deploys. Every job name is
automatically prefixed with `<your-release-name>` (for example,
`<release-name>_<job-name>`). The pack creates the following jobs:

* signoz
* clickhouse
* otel_collector
* schema_migrator_sync
* schema_migrator_async

Apply the policy to each of these jobs using the following command pattern:

```bash
nomad acl policy apply \
  -namespace <your-shared-namespace> \
  -description "SigNoz Shared Variables policy" \
  -job <your-release-name>_job_name \
  <your-release-name>_job_name \
  signoz-shared-vars.policy.hcl
```
Replace `<your-release-name>_job_name` with each job name from the list above.

### Step 3: Create Persistent Volumes

The pack requires three separate host volumes for data persistence. Here's an
example volume configuration:

```hcl
# signoz-volume.hcl
namespace = "default"
name      = "signoz-db"
type      = "host"

plugin_id = "mkdir"

capability {
  access_mode     = "single-node-single-writer"
  attachment_mode = "file-system"
}
```

Create the volume:

```bash
nomad volume create ./signoz-volume.hcl
```

**Important:** Create three separate volumes:
* One for ClickHouse data
* One for ZooKeeper data
* One for SigNoz application data

You'll reference these volume names when deploying the pack.

## Deployment

### Deploy with Volume Names

**Required:** You must specify all three volume names when deploying:

```bash
nomad-pack run signoz \
  --release-name=<your-release-name> \
  --var=signoz_volume_name=<SIGNOZ_VOLUME> \
  --var=clickhouse_volume_name=<CLICKHOUSE_VOLUME> \
  --var=zookeeper_volume_name=<ZOOKEEPER_VOLUME>
```

> [!WARNING]
> If a job under this pack fails due to a "Failed Validation" error for ClickHouse variables (this can occur if ClickHouse is not yet available and the variables do not exist), it will automatically retry.
> However, if all retry attempts are exhausted and the job still fails,
> check its status using `nomad job status <job-name>` or in the Nomad UI,
> then re-run the job manually.

### Preview Before Deploying

Render and inspect the job specifications:

```bash
nomad-pack render signoz
```

## Service Discovery

The pack automatically registers these services in Consul with health checks:

| Service | Health Checks | Purpose |
|---------|--------------|---------|
| `clickhouse` | HTTP + TCP | Database access |
| `zookeeper` | Client and admin endpoints | Coordination service |
| `signoz` | HTTP (public/internal) + OpAMP TCP | Main application |
| `signoz-otel-collector-otlp` | TCP metrics/OTLP | GRPC Telemetry collection |
| `signoz-otel-collector-http` | TCP metrics | HTTP telemetry endpoint |

These registrations enable inter-service communication and monitoring through Consul.

## Configuration

Customize your deployment by modifying `variables.hcl` or passing variables via
Pack's `--var` argument.

### Required

* `config`: A path on disk where the Clickhouse and Signoz configuration files
  live. You'll need this directory tree to match the one in the `config`
  directory of this Pack.

### General Configuration

* `release_name`: A top-level name for all the jobs, volumes, etc. this Pack deploys.
* `namespace`: Which namespace to deploy to.

### Container Versions
* `signoz_version`: SigNoz application image
* `otel_collector_version`: OpenTelemetry Collector image
* `clickhouse_version`: ClickHouse database image
* `zookeeper_version`: ZooKeeper image

### Resource Allocation
* `signoz_cpu`, `signoz_memory`: SigNoz resources
* `clickhouse_cpu`, `clickhouse_memory`: ClickHouse resources
* `zookeeper_cpu`, `zookeeper_memory`: ZooKeeper resources
* `otel_collector_cpu`, `otel_collector_memory`: Collector resources

### Network Configuration
* `clickhouse_tcp_port`, `clickhouse_http_port`: ClickHouse endpoints
* `otel_collector_otlp_port`, `otel_collector_otlp_http_port`: Collector endpoints

### Authentication
* `clickhouse_user`: ClickHouse database credentials

### Persistent Storage
* `signoz_volume_name`: Volume for SigNoz data
* `clickhouse_volume_name`: Volume for ClickHouse data
* `zookeeper_volume_name`: Volume for ZooKeeper data

### Scaling
* `otel_collector_count`: Number of collector replicas

## Next Steps

After deployment, access SigNoz through its registered Consul service endpoint
and begin collecting observability data from your applications.

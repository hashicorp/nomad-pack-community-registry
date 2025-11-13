# SigNoz on HashiCorp Nomad

Deploy the complete [SigNoz](https://signoz.io) observability stack on HashiCorp Nomad. This pack includes ClickHouse, ZooKeeper, the SigNoz application, and the OpenTelemetry Collector, all running as Docker containers via Nomad's [Docker driver](https://www.nomadproject.io/docs/drivers/docker).

## Prerequisites

Ensure your environment has:

- A running Nomad cluster
- Consul enabled for service discovery
- Nomad variable store configured
- Host volumes set up for persistent storage

## Setup Guide

### Step 1: Configure ClickHouse Password

Store your ClickHouse password securely using Nomad variables:

```hcl
# spec.nv.hcl
# Use path "nomad/jobs" to make it accessible to all jobs in the pack
path = "nomad/jobs/<your_pack_release_name>"

items {
  clickhouse_password = "your_clickhouse_password"  # Change this
}
```

Load the variables:

```bash
nomad var put @spec.nv.hcl
```

### Step 2: Create Access Policy

Define a policy that grants tasks read access to your variables:

```hcl
# signoz-shared-vars.policy.hcl
namespace "<your-shared-namespace>" {
  variables {
    path "nomad/jobs/<your_release_name>" {
      capabilities = ["read"]
    }
  }
}
```

Apply the policy:

```bash
nomad acl policy apply \
  -namespace <your-shared-namespace> \
  -description "SigNoz Shared Variables policy" \
  signoz-shared-vars \
  signoz-shared-vars.policy.hcl
```

### Step 3: Create Persistent Volumes

The pack requires three separate host volumes for data persistence. Here's an example volume configuration:

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
nomad volume create packs/signoz/templates/volumes/signoz-volume.hcl
```

**Important:** Create three separate volumes:
- One for ClickHouse data
- One for ZooKeeper data  
- One for SigNoz application data

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

## Configuration Options

Customize your deployment by modifying `variables.hcl`. Key configuration categories:

### Container Versions
- `signoz_version` — SigNoz application image
- `otel_collector_version` — OpenTelemetry Collector image
- `clickhouse_version` — ClickHouse database image
- `zookeeper_version` — ZooKeeper image

### Resource Allocation
- `signoz_cpu`, `signoz_memory` — SigNoz resources
- `clickhouse_cpu`, `clickhouse_memory` — ClickHouse resources
- `zookeeper_cpu`, `zookeeper_memory` — ZooKeeper resources
- `otel_collector_cpu`, `otel_collector_memory` — Collector resources

### Network Configuration
- `clickhouse_tcp_port`, `clickhouse_http_port` — ClickHouse endpoints
- `otel_collector_otlp_port`, `otel_collector_otlp_http_port` — Collector endpoints

### Authentication
- `clickhouse_user` — ClickHouse database credentials

### Persistent Storage
- `signoz_volume_name` — Volume for SigNoz data
- `clickhouse_volume_name` — Volume for ClickHouse data
- `zookeeper_volume_name` — Volume for ZooKeeper data

### Scaling
- `otel_collector_count` — Number of collector replicas

## Next Steps

After deployment, access SigNoz through its registered Consul service endpoint and begin collecting observability data from your applications.
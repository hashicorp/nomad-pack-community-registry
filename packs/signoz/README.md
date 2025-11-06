# SigNoz

Easily deploy the [SigNoz](https://signoz.io) observability stack—including ClickHouse, ZooKeeper, the SigNoz application, and the OpenTelemetry Collector—on HashiCorp Nomad. This pack runs services as Docker containers using Nomad’s [Docker driver](https://www.nomadproject.io/docs/drivers/docker).

## Prerequisites

- An operational Nomad cluster
- Consul enabled for service discovery
- Variable store for sensitive values (e.g., ClickHouse password)
- Host volumes created for persistent storage

### Setting Required Variables

Before deploying, store your ClickHouse password using Nomad variables:

```hcl
# spec.nv.hcl
path = "nomad/jobs/signoz"

items {
  clickhouse_password = "your_clickhouse_password"  # Update this value
}
```

Load variables into Nomad with:

```bash
nomad var put @spec.nv.hcl
```

### Creating Persistent Host Volumes

This pack uses Nomad host volumes (via the built-in `mkdir` plugin) to persist data for each major component: ClickHouse, ZooKeeper, and SigNoz itself. 

To create an example host volume:

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

Create the volume with:

```bash
nomad volume create packs/signoz/templates/volumes/signoz-volume.hcl
```

> **Note:**  
> Create a separate volume for each of ClickHouse, ZooKeeper, and SigNoz data.  
> When running the pack, supply the names as variables:  
> `nomad run --signoz_volume_name <SIGNOZ_VOLUME> --clickhouse_volume_name <CLICKHOUSE_VOLUME> --zookeeper_volume_name <ZOOKEEPER_VOLUME>`

## Consul Service Registration

On deployment, the pack registers multiple services in Consul for service discovery and health checking:

- `clickhouse`: HTTP + TCP health checks
- `zookeeper`: Client and admin endpoint health checks
- `signoz`: Public/internal HTTP and OpAMP TCP checks
- `signoz-otel-collector` + `signoz-otel-collector-otlp[*]`: Metrics/OTLP TCP checks

These registrations allow inter-service communication and convenient monitoring via Consul.

## Running the Pack

To deploy SigNoz with defaults:

```bash
nomad-pack run signoz
```

To first render and inspect jobs:

```bash
nomad-pack render signoz
```
## Configuration

Customize variables in `variables.hcl`. Common settings include:

- **Versions**:
  - `signoz_version` – SigNoz application image version
  - `otel_collector_version` – OTEL Collector image version
  - `clickhouse_version` – ClickHouse DB image version
  - `zookeeper_version` – Zookeeper image version

- **Resource Allocation**:
  - `signoz_cpu`, `signoz_memory` – SigNoz app resources
  - `clickhouse_cpu`, `clickhouse_memory` – ClickHouse resources
  - `zookeeper_cpu`, `zookeeper_memory` – ZooKeeper resources
  - `otel_collector_cpu`, `otel_collector_memory` – Collector resources

- **Network**:
  - `clickhouse_tcp_port`, `clickhouse_http_port` – ClickHouse endpoints
  - `otel_collector_otlp_port`, `otel_collector_otlp_http_port` – Collector endpoints

- **Authentication**:
  - `clickhouse_user`, `clickhouse_password` – ClickHouse DB credentials
  - `signoz_admin_email`, `signoz_admin_password` – (Optional) SigNoz admin login

- **Persistence**:
  - `signoz_volume_name` – Volume for SigNoz data
  - `clickhouse_volume_name` – Volume for ClickHouse data
  - `zookeeper_volume_name` – Volume for ZooKeeper data

- **Deployment & Scaling**:
  -  `otel_collector_count` – Control number of replicas
# SigNoz

This pack deploys [SigNoz](https://signoz.io) observability stack on Nomad, including ClickHouse, ZooKeeper, the SigNoz application, and the OpenTelemetry Collector. The service runs as a Docker container using the [Docker](https://www.nomadproject.io/docs/drivers/docker) driver.

### Prerequisites
- Nomad cluster up and running
- Consul for service discovery (required by this pack)

### Consul usage
This pack registers multiple services in Consul for discovery and health checking. After deployment, you should see the following Consul services:
- `clickhouse` (HTTP and TCP checks)
- `zookeeper` (TCP/HTTP checks for client and admin ports)
- `signoz` (public HTTP, internal HTTP, and OpAMP TCP checks)
- `signoz-otel-collector` (metrics HTTP) and `signoz-otel-collector-otlp`/`signoz-otel-collector-otlp-http` (TCP checks)

These are used internally for inter-service communication and provide convenient endpoints for monitoring the health of each component.

### Persistent Storage
The pack uses Nomad host volumes (via the built-in `mkdir` plugin) to persist data:
- ClickHouse data: volume name `clickhouse-data`
- ZooKeeper data: volume name `zookeeper-data`
- SigNoz app data: volume name `signoz-db`

Volume specs are provided here:
- `templates/volumes/clickhouse-volume.hcl`
- `templates/volumes/zookeeper-volume.hcl`
- `templates/volumes/signoz-volume.hcl`

Create the volumes before running the pack:
```bash
nomad volume create packs/signoz/templates/volumes/clickhouse-volume.hcl
nomad volume create packs/signoz/templates/volumes/zookeeper-volume.hcl
nomad volume create packs/signoz/templates/volumes/signoz-volume.hcl
```

You can override the default volume names with variables:
- `clickhouse_volume_name` (default: `clickhouse-data`)
- `zookeeper_volume_name` (default: `zookeeper-data`)
- `signoz_volume_name` (default: `signoz-db`)

### Key ports
- SigNoz UI: 8080
- OTLP gRPC: 4317
- OTLP HTTP: 4318
- ClickHouse HTTP: 8123, TCP: 9000

### Running the pack
Render and run with defaults:
```bash
nomad-pack run signoz
```

Or render to inspect jobs first:
```bash
nomad-pack render signoz
```

Useful output endpoints after deploy:
- SigNoz UI: `http://<nomad-client-ip>:8080`
- OTLP gRPC: `http://<nomad-client-ip>:4317`
- OTLP HTTP: `http://<nomad-client-ip>:4318`

### Configuration
All configurable variables are listed in `variables.hcl`. Common ones:
- Versions: `signoz_version`, `otel_collector_version`, `clickhouse_version`
- Resources: `*_cpu`, `*_memory`
- Ports: `*_*_port`
- ClickHouse auth: `clickhouse_user`, `clickhouse_password`, `clickhouse_secure`



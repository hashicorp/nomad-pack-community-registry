# OpenStudio Server

This pack deploys the full OpenStudio Server stack on Nomad:
- Web + web-background services
- Worker service with optional autoscaling
- MongoDB, Redis, and Rserve backends
- Optional backup/restore and verification batch jobs

## Requirements

- Nomad cluster with Docker driver enabled
- Consul integrated with Nomad for service discovery
- Host volumes or CSI volumes for persistent MongoDB/Redis storage
- (Optional) Vault for secret injection
- (Optional) Nomad Autoscaler when `worker_autoscaling_enabled = true`

## Usage

```bash
nomad-pack run ./packs/openstudio-server
```

Render and inspect first if desired:

```bash
nomad-pack render ./packs/openstudio-server
```

## Variables

All configurable inputs are defined in [`variables.hcl`](./variables.hcl).

Commonly overridden variables include:
- `job_name`
- `datacenters`
- `mongodb_storage_type` / `mongodb_volume_source`
- `redis_storage_type` / `redis_volume_source`
- `nfs_shared_volume_enabled` / `nfs_volume_source`
- `worker_count` and autoscaling variables
- `ingress_domain` and `ingress_tls_enabled`

For full operational guidance and deployment examples, see the source repository:
<https://github.com/anchapin/openstudio-server-nomad-pack>

## License

This pack is dual-licensed under MIT or BSD-3-Clause.
See [LICENSE](../../LICENSE), [LICENSE-MIT](../../LICENSE-MIT), and [LICENSE-BSD-3-CLAUSE](../../LICENSE-BSD-3-CLAUSE).

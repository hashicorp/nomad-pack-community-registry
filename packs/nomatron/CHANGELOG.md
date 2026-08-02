## Version v0.2.0 (2026-08-02)

### Added

- **Secrets backends:** `secrets_backend` supports `pack_vars` (default), `nomad_var` (recommended for production), and `vault`. Runtime secrets are injected via Nomad template blocks — not stored in the job specification.
- **Production validation:** `deployment_profile=production|ha` now requires `server.trusted_origins`, and `http_port_static` when `load_balancer_mode=none`.
- **HA runbook:** post-deploy output documents one-time database initialization for HA.
- **Secrets guide:** [docs/common/secrets.md](https://github.com/nomatronio/nomatron-pack/blob/main/docs/common/secrets.md)
- Example vars: `production.byodb.nomad-var.vars.hcl.example`, `production.byodb.vault.vars.hcl.example`

### Removed

- **`database_mode=dev`** — use `nomatron server --dev` to trial Nomatron; this pack is for lab (`provision`) or production (`byodb`) on Nomad only.
- `dev` variable object and `examples/dev.vars.hcl.example`.

### Fixed

- **Binary artifact path:** release tarballs unpack under the task `local/bin/` directory; exec `command` uses that relative path.
- Config file path for Docker tasks: use `${NOMAD_TASK_DIR}/config/nomatron.hcl` (Nomad mounts `local/` as `NOMAD_TASK_DIR`, so do not double the `local/` prefix).
- Serf `node_name` default uses Nomad template `{{ env "NOMAD_ALLOC_ID" }}` instead of literal `${NOMAD_ALLOC_ID}` in `nomatron.hcl` (Nomatron's HCL parser rejects variable interpolation).
- Default `nomatron_version` updated to `v0.1.0-rc.20`.
- Licensing defaults aligned with AWS reference architecture: always emit `keygen_base_url = "https://api.keygen.sh"`; optional `trusted_account_id`, `trusted_public_key`, and `trusted_product_ids`.
- Added `examples/mac-dev.vars.hcl.example` and `.gitignore` for local `*.vars.hcl` secret files.
- Document host volume setup for `database_mode=provision`; default `postgres.volume_path` renamed to `nomatron-postgres` (host volume name, not filesystem path).

### Changed

- Default `database_mode=provision`, `runtime=docker` — lab quickstart requires a vars file (license + secrets).
- Repository layout: synced pack contains registry files only; platform guides in repo-root `docs/`, example vars in repo-root `examples/`.
- Default database pool limits: `max_open_conns=25`, `max_idle_conns=10`
- `deployment_profile` now enforced at render time with profile-specific validation

### Added

- **Platform setup guides** under `docs/` — AWS, Azure, GCP, Proxmox, OpenStack, VMware; dedicated nodes, load balancing, ports, Nomad client setup
- **README:** nomad-pack install, registry vs clone, plan/run workflow, command reference
- **CONTRIBUTING.md:** community registry initial PR and per-release sync checklist
- **LICENSE:** Mozilla Public License 2.0 (MPL-2.0)
- **`.ci/vars-*.hcl`:** community registry CI render/validate fixtures
- **GitHub Actions:** `validate-pack.yml` on PRs; `sync-community-registry.yml` opens upstream PR on `v*` tags
- **Reference architecture profiles** with validated constraints and gold-standard example vars (`production.byodb`, `production.byodb.binary`, `ha.byodb`, `ha.provision-lab`)
- Post-deploy runbook in pack outputs
- **Provision mode HA:** when `database_mode=provision` and `count > 1`, deploy one Postgres task and spread Nomatron servers; Postgres discovery via `nomadService` or Consul `service` template depending on `service_provider`
- README reference architecture section (profile matrix, decision guide, Nomad version requirements, Nomad client sizing for AWS/GCP/Azure)
- Full Nomatron server deployment replacing hello-world scaffold
- `database_mode`: BYODB (`byodb`) or optional colocated Postgres (`provision`)
- `runtime`: Docker container or binary (artifact download or host path)
- HA support with configurable `count`, Serf clustering, and spread constraints
- Load balancer modes: `none`, `service` (Traefik/Fabio tags), and `traefik` (deploy Traefik system job)
- Complete Nomatron configuration via `server`, `database`, `serf`, `licensing`, `telemetry`, and `operations` objects
- Deployment profiles: `quickstart`, `production`, `ha`
- Pack outputs with post-deploy URLs and next steps
- README: Nomad version requirements table; Consul vs native service discovery for provision HA
- `network_mode` variable (`bridge` or `standard`) for Linux CNI vs macOS dev without bridge CNI

## Version v0.0.1

Initial scaffold release.

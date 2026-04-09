# nomad_snapshot_agent

Deploys the **Nomad Enterprise** `operator snapshot agent` as a long-running
`service` job. Supports four storage backends switchable via a single variable:

| `storage_backend` | Where snapshots go               |
|-------------------|----------------------------------|
| `local` (default) | Host directory on the client     |
| `s3`              | AWS S3 or any S3-compatible store|
| `azure`           | Azure Blob Storage               |
| `gcs`             | Google Cloud Storage             |

## Requirements

- **Nomad Enterprise** license
- `raw_exec` driver enabled on client nodes
- `nomad` binary present on client hosts
- If ACLs enabled: token with `operator:write` or `operator:snapshot-save` + `operator:license-read`

---

## Pre-requisite: host volume (local storage only)

Add to your Nomad client config (`/etc/nomad.d/client.hcl`):

```hcl
host_volume "nomad-snapshot-data" {
  path      = "/opt/nomad/snapshots"
  read_only = false
}
```

```bash
sudo mkdir -p /opt/nomad/snapshots
sudo chown nomad:nomad /opt/nomad/snapshots
sudo systemctl restart nomad
```

---

## Deploy examples

```bash
# Local storage — daily snapshots, keep 30
np run nomad_snapshot_agent --registry=suyash-nomad-pack \
  --var storage_backend=local \
  --var local_path=/opt/nomad/snapshots \
  --var snapshot_interval=24h

# AWS S3 — every 6 hours, keep 60, using instance role (no keys needed)
np run nomad_snapshot_agent --registry=suyash-nomad-pack \
  --var storage_backend=s3 \
  --var aws_s3_bucket=my-nomad-snapshots \
  --var aws_s3_region=us-east-1 \
  --var snapshot_interval=6h \
  --var snapshot_retain=60

# AWS S3 — with explicit credentials + KMS encryption
np run nomad_snapshot_agent --registry=suyash-nomad-pack \
  --var storage_backend=s3 \
  --var aws_access_key_id=AKIA... \
  --var aws_secret_access_key=secret \
  --var aws_s3_bucket=my-nomad-snapshots \
  --var aws_s3_region=ap-south-1 \
  --var aws_s3_enable_kms=true

# MinIO (S3-compatible)
np run nomad_snapshot_agent --registry=suyash-nomad-pack \
  --var storage_backend=s3 \
  --var aws_s3_bucket=nomad-snapshots \
  --var aws_s3_region=us-east-1 \
  --var aws_s3_endpoint=http://minio.service.consul:9000

# Azure Blob Storage
np run nomad_snapshot_agent --registry=suyash-nomad-pack \
  --var storage_backend=azure \
  --var azure_account_name=mystorageaccount \
  --var azure_account_key=<key> \
  --var azure_container_name=nomad-snapshots

# Google Cloud Storage
np run nomad_snapshot_agent --registry=suyash-nomad-pack \
  --var storage_backend=gcs \
  --var gcs_bucket=my-nomad-snapshots
```

---

## Restore a snapshot

```bash
nomad operator snapshot restore /opt/nomad/snapshots/<snapshot-file>.snap
```

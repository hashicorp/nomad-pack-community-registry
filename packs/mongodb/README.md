# mongodb

Deploys a MongoDB instance on Nomad using the Docker driver with persistent
host volume storage, and configurable authentication.

## Requirements

- Nomad client with Docker driver enabled
- If `use_host_volume = true`: a host volume named `mongodb-data` (or your
  chosen name) must be configured on the Nomad client node

### Configure the host volume on your Nomad client

Add this to your client's HCL config (e.g. `/etc/nomad.d/client.hcl`):

```hcl
host_volume "mongodb-data" {
  path      = "/opt/nomad/volumes/mongodb"
  read_only = false
}
```

Then create the directory and restart:
```bash
sudo mkdir -p /opt/nomad/volumes/mongodb
sudo chown -R nomad:nomad /opt/nomad/volumes/mongodb
sudo systemctl restart nomad
```

## Deploy examples

```bash
# Dev/local — no persistence, no auth
nomad-pack run mongodb \
  --registry=suyash-nomad-pack \
  --var use_host_volume=false \
  --var auth_enabled=false

# Production — auth + persistence
nomad-pack run mongodb \
  --registry=suyash-nomad-pack \
  --var root_password="supersecret" \
  --var datacenters='["prod-dc1"]'

# Specific version + custom port
nomad-pack run mongodb \
  --registry=suyash-nomad-pack \
  --var mongo_image_tag="6.0" \
  --var mongo_port=27018 \
  --var root_password="supersecret"
```

## Variables

See `variables.hcl` for the full list. Key ones:

| Variable              | Default         | Description                              |
|-----------------------|-----------------|------------------------------------------|
| `mongo_image_tag`     | `7.0`           | MongoDB version                          |
| `auth_enabled`        | `true`          | Enable --auth                            |
| `root_username`       | `admin`         | Root user (when auth enabled)            |
| `root_password`       | `changeme`      | ⚠ Change this in production             |
| `use_host_volume`     | `true`          | Mount host volume for persistence        |
| `host_volume_name`    | `mongodb-data`  | Nomad host volume name on client         |
| `mongo_port`          | `27017`         | Static host port                         |
| `cpu`                 | `1024`          | MHz                                      |
| `memory`              | `1024`          | MB                                       |
| `memory_max`          | `2048`          | MB (oversubscription ceiling)            |

# nomad_debug_bundle

A Nomad Pack that periodically runs `nomad operator debug` and saves the resulting
debug bundle archive to a directory on the host machine.

## Use case

Deploy this pack so that debug bundles are automatically collected on a schedule
(default: every 24 hours). If an issue arises, customers can share the bundle from
the path without needing to manually run any commands.

## Requirements

- The `raw_exec` driver must be enabled on Nomad clients.
- The `nomad` binary must be present on the client host at the configured path.
- The output directory must be writable by the Nomad client process.
- If ACLs are enabled, provide a token with `node:read`, `agent:read`, `operator:read`,
  `list-jobs` (all namespaces), and `agent:write` capabilities.

## Variables

See `variables.hcl` for the full list. Key ones:

| Variable         | Default                  | Description                        |
|------------------|--------------------------|------------------------------------|
| `cron_schedule`  | `0 */12 * * *`           | How often to run (every 12 hours)  |
| `output_dir`     | `/opt/nomad/debug-bundles` | Host path to save archives        |
| `debug_duration` | `2m`                     | How long each capture runs         |
| `retention_days` | `7`                      | Days to keep old bundles           |
| `nomad_token`    | `""`                     | ACL token (if ACLs enabled)        |

## Deploy

```bash
# Every 12 hours (default)
nomad-pack run . --var output_dir=/opt/nomad/debug-bundles

# Every 6 hours
nomad-pack run . --var cron_schedule="0 */6 * * *" --var output_dir=/opt/nomad/debug-bundles

# With ACL token
nomad-pack run . --var nomad_token="<your-token>" --var output_dir=/opt/nomad/debug-bundles
```

## Enable raw_exec on your Nomad clients
In your Nomad client config file (e.g. /etc/nomad.d/client.hcl), make sure this is set:
```
plugin "raw_exec" {
  config {
    enabled = true
  }
}
```
Then restart the client: ```systemctl restart nomad```

## Prepare the output directory on client hosts
```
sudo mkdir -p /opt/nomad/debug-bundles
sudo chown nomad:nomad /opt/nomad/debug-bundles
```

## Render and deploy
#### Preview the rendered jobspec first
```
nomad-pack render . --var output_dir=/opt/nomad/debug-bundles
```

#### Deploy (every 24 hours)
```
nomad-pack run . --var output_dir=/opt/nomad/debug-bundles
```

#### Deploy (every 6 hours)
```
nomad-pack run . \
  --var cron_schedule="0 */6 * * *" \
  --var output_dir=/opt/nomad/debug-bundles \
  --var debug_duration="2m" \
  --var retention_days=14
```

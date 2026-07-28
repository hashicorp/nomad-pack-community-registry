[[ if var "enable_batch_verification" . ]]
job "[[ var "job_name" . ]]-batch-verify" {
  region      = "[[ var "region" . ]]"
  datacenters = [[ var "datacenters" . | toJson ]]
  namespace   = "[[ var "nomad_namespace" . ]]"
  type        = "batch"

  group "batch-verification" {
    count = 1

    restart {
      attempts = 0
      mode     = "fail"
    }

    task "verify-connectivity" {
      driver = "docker"

      config {
        image   = "[[ var "verification_image" . ]]"
        command = "/bin/sh"
        args    = ["-c", "local/verify-connectivity.sh"]
      }

      template {
        destination = "local/verify-connectivity.sh"
        perms       = "755"
        data        = <<EOH
#!/bin/sh
set -eu

failed=0
total=0
timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

echo "batch_verification_started timestamp=$timestamp"

for target in [[ range var "verification_targets" . ]]"[[ . ]]" [[ end ]]; do
  if [ -z "$target" ]; then
    continue
  fi

  total=$(expr "$total" + 1)

  component=$(echo "$target" | cut -d= -f1)
  endpoint=$(echo "$target" | cut -d= -f2)
  host=$(echo "$endpoint" | cut -d: -f1)
  port=$(echo "$endpoint" | cut -d: -f2)

  ping_ok=0
  tcp_ok=0

  if ping -c 1 -W 2 "$host" >/dev/null 2>&1; then
    ping_ok=1
  fi

  if nc -z -w 2 "$host" "$port" >/dev/null 2>&1; then
    tcp_ok=1
  fi

  status="fail"
  if [ "$ping_ok" -eq 1 ] && [ "$tcp_ok" -eq 1 ]; then
    status="pass"
  else
    failed=$(expr "$failed" + 1)
  fi

  echo "batch_verification_result component=$component host=$host port=$port ping=$ping_ok tcp=$tcp_ok status=$status"
done

passed=$(expr "$total" - "$failed")
echo "batch_verification_summary total=$total passed=$passed failed=$failed"

if [ "$failed" -gt 0 ]; then
  exit 1
fi
EOH
      }

      resources {
        cpu    = 100
        memory = 64
      }
    }
  }
}
[[ end ]]

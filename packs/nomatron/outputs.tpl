Nomatron pack deployed — reference architecture profile : [[ var "deployment_profile" . ]]

Job : [[ template "job_name" . ]]
Profile : [[ var "deployment_profile" . ]]
Database mode : [[ var "database_mode" . ]]
Runtime : [[ var "runtime" . ]]
Nomatron servers : [[ var "count" . ]]
Version : [[ var "nomatron_version" . ]]
Load balancer : [[ var "load_balancer_mode" . ]]
Service provider : [[ var "service_provider" . ]]

API address : [[ template "effective_api_addr" . ]]
Health check : [[ template "effective_api_addr" . ]] / api / v1 / health ? bootstrap = ok
Web UI : [[ template "effective_api_addr" . ]] / ui
Setup wizard : [[ template "effective_api_addr" . ]] / ui / setup

[[- if eq (var "database_mode" .) "provision" ]]
Database : provisioned Postgres(lab only — not production) [[ if gt (var "count" .) 1 ]] — 1 Postgres, [[ var "count" . ]] Nomatron servers[[ end ]]
[[- else ]]
Database : BYODB writer — [[ if ne (var "database.host" .) "" ]][[ var "database.host" . ]] : [[ var "database.port" . ]] / [[ var "database.name" . ]][[ else ]]see database.connection_string[[ end ]]
[[- end ]]

[[- if eq (var "load_balancer_mode" .) "traefik" ]]
Traefik job : [[ var "traefik.job_name" . ]](HTTP port [[ var "traefik.http_port" . ]])
[[- end ]]

---Post-deploy runbook - --

Secrets(must stay stable for this environment) :
[[- $secretsBackend := var "secrets_backend" . -]]
[[- if eq $secretsBackend "pack_vars" ]]
[] encryption_key, license_key, cluster_key — in vars file ; same values on every redeploy
[[- else if eq $secretsBackend "nomad_var" ]]
[] Nomad Variable at [[ var "secrets_nomad_var.path" . ]] — encryption_key, license_key, cluster_key, db_url[[ if gt (var "count" .) 1 ]], serf_encrypt_key[[ end ]]
[[- else ]]
[] Vault secret at [[ var "secrets_vault.path" . ]] — encryption_key, license_key, cluster_key, db_url[[ if gt (var "count" .) 1 ]], serf_encrypt_key[[ end ]]
[[- end ]]
[[- if gt (var "count" .) 1 ]]
[[- if eq $secretsBackend "pack_vars" ]]
[] serf.encrypt_key — identical on every Nomatron server
[[- end ]]
[[- end ]]
[[- if and (eq (var "deployment_profile" .) "ha") (eq (var "database_mode" .) "byodb") ]]
[] HA database init — run once before all servers serve traffic :
-Option A : complete / ui / setup on the first healthy node after one server starts
-Option B : nomad alloc exec < first-alloc > nomatron database init - -config $ NOMAD_TASK_DIR / config / nomatron.hcl
bootstrap.auto_init_database only runs for count = 1 ; do not enable it for HA
[[- end ]]

Database :
[[- if eq (var "database_mode" .) "byodb" ]]
[] Writer endpoint reachable from every Nomatron allocation
[] TLS enabled(sslmode = require or stricter)
[] Pool size : count([[ var "count" . ]]) × max_open_conns < Postgres max_connections
[] Initialize via / ui / setup or bootstrap.auto_init_database(first boot only)
[[- else if eq (var "database_mode" .) "provision" ]]
[] Lab provision only — migrate to BYODB before production
[] Initialize via / ui / setup or bootstrap.auto_init_database(first boot only)
[[- end ]]

Nomatron :
[] server.api_addr matches the URL users and webhooks use
[[- if ne (var "server.api_addr" .) "" ]]
[] api_addr configured : [[ var "server.api_addr" . ]]
[[- else if ne (var "public_hostname" .) "" ]]
[] public_hostname configured : [[ var "public_hostname" . ]]
[[- end ]]
[] Health check returns ok = true after database initialized
[] Register Nomad cluster(s) in the Nomatron UI

[[- if gt (var "count" .) 1 ]]
HA :
[] Serf cluster formed — verify retry_join addresses match deployed nodes
[] Nomad spread placed servers on distinct clients(check : nomad job status)
[[- end ]]

Upgrade : change nomatron_version and redeploy(rolling update when count > 1).

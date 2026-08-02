[[- define "job_name" -]]
[[ coalesce ( var "job_name" .) (meta "pack.name" .) | quote ]]
[[- end -]]

[[ define "region" -]]
[[- if var "region" . -]]
  region = "[[ var "region" . ]]"
[[- end -]]
[[- end -]]

[[ define "constraints" -]]
[[ range $idx, $constraint := . ]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    [[ if $constraint.operator -]]
    operator  = [[ $constraint.operator | quote ]]
    [[ end -]]
    value     = [[ $constraint.value | quote ]]
  }
[[ end -]]
[[- end -]]

[[- define "job_placement" -]]
  node_pool   = [[ var "node_pool" . | quote ]]
[[- if gt (len (var "constraints" .)) 0 ]]
  [[ template "constraints" (var "constraints" .) ]]
[[- end ]]
[[- end -]]

[[ define "env_vars" -]]
        [[- range $idx, $var := . ]]
        [[ $var.key ]] = [[ $var.value | quote ]]
        [[- end ]]
[[- end ]]

[[- define "validate_deployment" -]]
[[- $profile := var "deployment_profile" . -]]
[[- $count := var "count" . -]]
[[- $dbMode := var "database_mode" . -]]
[[- if and (ne $profile "quickstart") (ne $profile "production") (ne $profile "ha") -]]
[[ fail "deployment_profile must be quickstart, production, or ha." ]]
[[- end -]]
[[- if and (ne $dbMode "byodb") (ne $dbMode "provision") -]]
[[ fail "database_mode must be byodb or provision. To try Nomatron without deploying on Nomad, run: nomatron server --dev" ]]
[[- end -]]
[[- if eq $profile "production" -]]
[[- if ne $dbMode "byodb" -]]
[[ fail "deployment_profile=production requires database_mode=byodb with HA PostgreSQL (managed service, Patroni leader URL, or equivalent). Use deployment_profile=quickstart for provisioned Postgres." ]]
[[- end -]]
[[- if gt $count 1 -]]
[[ fail "deployment_profile=production requires count=1. Use deployment_profile=ha for multiple Nomatron servers." ]]
[[- end -]]
[[- if and (eq (var "database.sslmode" .) "disable") (or (eq (var "database.connection_string" .) "") (not (contains "sslmode=" (var "database.connection_string" .)))) -]]
[[ fail "deployment_profile=production requires TLS to PostgreSQL: set database.sslmode=require or include sslmode=require in database.connection_string." ]]
[[- end -]]
[[- if and (eq (var "server.api_addr" .) "") (eq (var "public_hostname" .) "") -]]
[[ fail "deployment_profile=production requires server.api_addr or public_hostname so Nomatron advertises the URL users and webhooks reach." ]]
[[- end -]]
[[- if eq (len (var "server.trusted_origins" .)) 0 -]]
[[ fail "deployment_profile=production requires server.trusted_origins (public HTTPS origin for CSRF). Example: [\"https://nomatron.example.com\"]" ]]
[[- end -]]
[[- if and (eq (var "load_balancer_mode" .) "none") (eq (var "http_port_static" .) 0) -]]
[[ fail "deployment_profile=production with load_balancer_mode=none requires http_port_static (typically 4649) so a cloud load balancer can reach Nomatron on client host ports." ]]
[[- end -]]
[[- end -]]
[[- if eq $profile "ha" -]]
[[- if ne $dbMode "byodb" -]]
[[ fail "deployment_profile=ha requires database_mode=byodb. For lab Nomatron HA with provisioned Postgres, use deployment_profile=quickstart with count>1 (see https://github.com/nomatronio/nomatron-pack/blob/main/examples/ha.provision-lab.vars.hcl.example)." ]]
[[- end -]]
[[- if lt $count 2 -]]
[[ fail "deployment_profile=ha requires count >= 2 (recommended: 3)." ]]
[[- end -]]
[[- if and (eq (var "database.sslmode" .) "disable") (or (eq (var "database.connection_string" .) "") (not (contains "sslmode=" (var "database.connection_string" .)))) -]]
[[ fail "deployment_profile=ha requires TLS to PostgreSQL: set database.sslmode=require or include sslmode=require in database.connection_string." ]]
[[- end -]]
[[- if and (eq (var "server.api_addr" .) "") (eq (var "public_hostname" .) "") -]]
[[ fail "deployment_profile=ha requires server.api_addr or public_hostname so Nomatron advertises the URL users and webhooks reach." ]]
[[- end -]]
[[- if eq (len (var "server.trusted_origins" .)) 0 -]]
[[ fail "deployment_profile=ha requires server.trusted_origins (public HTTPS origin for CSRF). Example: [\"https://nomatron.example.com\"]" ]]
[[- end -]]
[[- if and (eq (var "load_balancer_mode" .) "none") (eq (var "http_port_static" .) 0) -]]
[[ fail "deployment_profile=ha with load_balancer_mode=none requires http_port_static (typically 4649) so a cloud load balancer can reach Nomatron on client host ports." ]]
[[- end -]]
[[- end -]]
[[- if eq (var "database_mode" .) "provision" -]]
[[- if ne (var "network_mode" .) "bridge" -]]
[[ fail "database_mode=provision requires network_mode=bridge so Nomatron and Postgres can share a network namespace." ]]
[[- end -]]
[[- end -]]
[[- $secretsBackend := var "secrets_backend" . -]]
[[- if and (ne $secretsBackend "pack_vars") (ne $secretsBackend "nomad_var") (ne $secretsBackend "vault") -]]
[[ fail "secrets_backend must be pack_vars, nomad_var, or vault." ]]
[[- end -]]
[[- if eq $secretsBackend "nomad_var" -]]
[[- if eq (var "secrets_nomad_var.path" .) "" -]]
[[ fail "secrets_backend=nomad_var requires secrets_nomad_var.path (for example nomad/jobs/nomatron/nomatron-server/nomatron)." ]]
[[- end -]]
[[- else if eq $secretsBackend "vault" -]]
[[- if eq (var "secrets_vault.path" .) "" -]]
[[ fail "secrets_backend=vault requires secrets_vault.path (for example secret/data/nomatron/production)." ]]
[[- end -]]
[[- end -]]
[[- if eq $dbMode "byodb" -]]
[[- if eq $secretsBackend "pack_vars" -]]
[[- if and (eq (var "database.connection_string" .) "") (eq (var "database.host" .) "") -]]
[[ fail "database_mode=byodb requires database.connection_string or database.host." ]]
[[- end -]]
[[- if and (eq (var "database.connection_string" .) "") (eq (var "database.password" .) "") -]]
[[ fail "database_mode=byodb requires database.password when using component fields (database.host)." ]]
[[- end -]]
[[- else -]]
[[- if and (eq (var "database.connection_string" .) "") (eq (var "database.host" .) "") -]]
[[ fail "database_mode=byodb with secrets_backend=nomad_var|vault requires database.host for placement docs, or a non-secret database.connection_string prefix; store the full postgres URL in the Nomad Variable or Vault secret (db_url key)." ]]
[[- end -]]
[[- end -]]
[[- end -]]
[[- if gt $count 1 -]]
[[- if and (eq $secretsBackend "pack_vars") (eq (var "serf.encrypt_key" .) "") -]]
[[ fail "serf.encrypt_key is required when count > 1 and secrets_backend=pack_vars. Generate one with: nomatron keygen, or store serf_encrypt_key in Nomad Variables / Vault when using secrets_backend=nomad_var|vault." ]]
[[- end -]]
[[- if eq (len (var "serf.retry_join" .)) 0 -]]
[[ fail "serf.retry_join is required when count > 1." ]]
[[- end -]]
[[- end -]]
[[- $provider := var "service_provider" . -]]
[[- if and (ne $provider "nomad") (ne $provider "consul") -]]
[[ fail "service_provider must be nomad or consul." ]]
[[- end -]]
[[- if and (eq $secretsBackend "pack_vars") (eq (var "secrets.encryption_key" .) "") -]]
[[ fail "secrets.encryption_key is required when secrets_backend=pack_vars. Generate one with: openssl rand -base64 32, or use secrets_backend=nomad_var|vault for production." ]]
[[- end -]]
[[- end -]]

[[- define "binary_artifact_command" -]]
local/bin/nomatron_[[ trimPrefix "v" (var "nomatron_version" .) ]]_linux_[[ var "binary_arch" . ]]/nomatron
[[- end -]]

[[- define "group_vault_block" -]]
[[- if eq (var "secrets_backend" .) "vault" ]]
    vault {
      policies = [[ var "secrets_vault.policies" . | toStringList ]]
    }
[[- end ]]
[[- end -]]

[[- define "nomatron_secrets_env_template" -]]
[[- if ne (var "secrets_backend" .) "pack_vars" ]]
[[- $path := var "secrets_nomad_var.path" . -]]
[[- $kEnc := coalesce (var "secrets_nomad_var.keys.encryption_key" .) "encryption_key" -]]
[[- $kLic := coalesce (var "secrets_nomad_var.keys.license_key" .) "license_key" -]]
[[- $kCluster := coalesce (var "secrets_nomad_var.keys.cluster_key" .) "cluster_key" -]]
[[- $kDB := coalesce (var "secrets_nomad_var.keys.db_url" .) "db_url" -]]
[[- $kRoot := coalesce (var "secrets_nomad_var.keys.root_password" .) "root_password" -]]
[[- $vPath := var "secrets_vault.path" . -]]
[[- $vEnc := coalesce (var "secrets_vault.keys.encryption_key" .) "encryption_key" -]]
[[- $vLic := coalesce (var "secrets_vault.keys.license_key" .) "license_key" -]]
[[- $vCluster := coalesce (var "secrets_vault.keys.cluster_key" .) "cluster_key" -]]
[[- $vDB := coalesce (var "secrets_vault.keys.db_url" .) "db_url" -]]
[[- $vRoot := coalesce (var "secrets_vault.keys.root_password" .) "root_password" -]]
      template {
        destination = "${NOMAD_SECRETS_DIR}/nomatron.env"
        env         = true
        change_mode = "restart"
        data        = <<EOH
[[- if eq (var "secrets_backend" .) "nomad_var" ]]
{{- with nomadVar "[[ $path ]]" }}
NOMATRON_ENCRYPTION_KEY = {{ index . "[[ $kEnc ]]" | toJSON }}
NOMATRON_LICENSE_KEY    = {{ index . "[[ $kLic ]]" | toJSON }}
NOMATRON_CLUSTER_KEY    = {{ index . "[[ $kCluster ]]" | toJSON }}
{{- if index . "[[ $kDB ]]" }}
NOMATRON_DB_URL         = {{ index . "[[ $kDB ]]" | toJSON }}
{{- end }}
{{- if index . "[[ $kRoot ]]" }}
NOMATRON_ROOT_PASSWORD  = {{ index . "[[ $kRoot ]]" | toJSON }}
{{- end }}
{{- end }}
[[- else if eq (var "secrets_backend" .) "vault" ]]
{{- with secret "[[ $vPath ]]" }}
NOMATRON_ENCRYPTION_KEY = {{ .Data.data.[[ $vEnc ]] | toJSON }}
NOMATRON_LICENSE_KEY    = {{ .Data.data.[[ $vLic ]] | toJSON }}
NOMATRON_CLUSTER_KEY    = {{ .Data.data.[[ $vCluster ]] | toJSON }}
{{- if .Data.data.[[ $vDB ]] }}
NOMATRON_DB_URL         = {{ .Data.data.[[ $vDB ]] | toJSON }}
{{- end }}
{{- if .Data.data.[[ $vRoot ]] }}
NOMATRON_ROOT_PASSWORD  = {{ .Data.data.[[ $vRoot ]] | toJSON }}
{{- end }}
{{- end }}
[[- end ]]
EOH
      }
[[- end ]]
[[- end -]]

[[- define "nomatron_serf_encrypt_key_hcl" -]]
[[- if gt (var "count" .) 1 ]]
[[- $path := var "secrets_nomad_var.path" . -]]
[[- $kSerf := coalesce (var "secrets_nomad_var.keys.serf_encrypt_key" .) "serf_encrypt_key" -]]
[[- $vPath := var "secrets_vault.path" . -]]
[[- $vSerf := coalesce (var "secrets_vault.keys.serf_encrypt_key" .) "serf_encrypt_key" -]]
[[- if eq (var "secrets_backend" .) "pack_vars" ]]
  encrypt_key = [[ var "serf.encrypt_key" . | quote ]]
[[- else if eq (var "secrets_backend" .) "nomad_var" ]]
  encrypt_key = "{{- with nomadVar "[[ $path ]]" }}{{ index . "[[ $kSerf ]]" | toJSON }}{{- end }}"
[[- else if eq (var "secrets_backend" .) "vault" ]]
  encrypt_key = "{{- with secret "[[ $vPath ]]" }}{{ .Data.data.[[ $vSerf ]] | toJSON }}{{- end }}"
[[- end ]]
[[- end ]]
[[- end -]]

[[- define "nomatron_database_connection_hcl" -]]
[[- if eq (var "secrets_backend" .) "pack_vars" ]]
  connection_string = [[ if and (eq (var "database_mode" .) "provision") (gt (var "count" .) 1) ]][[ if eq (var "service_provider" .) "consul" ]][[ printf "postgres://%s:%s@{{ with service %s }}{{ with index . 0 }}{{ .Address }}:{{ .Port }}{{ end }}{{ end }}/%s?sslmode=disable" (var "postgres.username" .) (var "postgres.password" .) (var "postgres.service_name" . | quote) (var "postgres.db_name" .) | quote ]][[ else ]][[ printf "postgres://%s:%s@{{ with nomadService %s }}{{ with index . 0 }}{{ .Address }}:{{ .Port }}{{ end }}{{ end }}/%s?sslmode=disable" (var "postgres.username" .) (var "postgres.password" .) (var "postgres.service_name" . | quote) (var "postgres.db_name" .) | quote ]][[ end ]][[ else if eq (var "database_mode" .) "provision" ]][[ printf "postgres://%s:%s@127.0.0.1:5432/%s?sslmode=disable" (var "postgres.username" .) (var "postgres.password" .) (var "postgres.db_name" .) | quote ]][[ else if ne (var "database.connection_string" .) "" ]][[ var "database.connection_string" . | quote ]][[ else ]][[ printf "postgres://%s:%s@%s:%v/%s?sslmode=%s" (var "database.username" .) (var "database.password" .) (var "database.host" .) (var "database.port" .) (var "database.name" .) (var "database.sslmode" .) | quote ]][[ end ]]
[[- else ]]
  # connection_string supplied at runtime via NOMATRON_DB_URL (Nomad Variable or Vault)
[[- end ]]
[[- end -]]

[[- define "nomatron_server_env_pack_vars" -]]
        NOMATRON_ENCRYPTION_KEY = [[ var "secrets.encryption_key" . | quote ]]
        NOMATRON_LICENSE_KEY    = [[ var "secrets.license_key" . | quote ]]
        NOMATRON_CLUSTER_KEY    = [[ var "secrets.cluster_key" . | quote ]]
[[- if ne (var "bootstrap.root_username" .) "" ]]
        NOMATRON_ROOT_USERNAME  = [[ var "bootstrap.root_username" . | quote ]]
[[- end ]]
[[- if ne (var "bootstrap.root_password" .) "" ]]
        NOMATRON_ROOT_PASSWORD  = [[ var "bootstrap.root_password" . | quote ]]
[[- end ]]
[[- end -]]

[[- define "nomatron_service_tags" -]]
[[- if gt (len (var "service_tags" .)) 0 -]]
[[ var "service_tags" . | toStringList ]]
[[- else -]]
[[- $hostname := var "public_hostname" . -]]
[[- if eq $hostname "" -]]
[[- $hostname = "nomatron.example.com" -]]
[[- end -]]
[[- $tags := list
  "traefik.enable=true"
  (printf "traefik.http.routers.nomatron.rule=Host(`%s`)" $hostname)
  "traefik.http.services.nomatron.loadbalancer.server.port=4649"
-]]
[[ $tags | toStringList ]]
[[- end -]]
[[- end -]]

[[- define "nomatron_db_url_env_pack_vars" -]]
        NOMATRON_DB_URL         = [[ if and (eq (var "database_mode" .) "provision") (gt (var "count" .) 1) ]][[ if eq (var "service_provider" .) "consul" ]][[ printf "postgres://%s:%s@{{ with service %s }}{{ with index . 0 }}{{ .Address }}:{{ .Port }}{{ end }}{{ end }}/%s?sslmode=disable" (var "postgres.username" .) (var "postgres.password" .) (var "postgres.service_name" . | quote) (var "postgres.db_name" .) | quote ]][[ else ]][[ printf "postgres://%s:%s@{{ with nomadService %s }}{{ with index . 0 }}{{ .Address }}:{{ .Port }}{{ end }}{{ end }}/%s?sslmode=disable" (var "postgres.username" .) (var "postgres.password" .) (var "postgres.service_name" . | quote) (var "postgres.db_name" .) | quote ]][[ end ]][[ else if eq (var "database_mode" .) "provision" ]][[ printf "postgres://%s:%s@127.0.0.1:5432/%s?sslmode=disable" (var "postgres.username" .) (var "postgres.password" .) (var "postgres.db_name" .) | quote ]][[ else if ne (var "database.connection_string" .) "" ]][[ var "database.connection_string" . | quote ]][[ else if ne (var "database.host" .) "" ]][[ printf "postgres://%s:%s@%s:%v/%s?sslmode=%s" (var "database.username" .) (var "database.password" .) (var "database.host" .) (var "database.port" .) (var "database.name" .) (var "database.sslmode" .) | quote ]][[ end ]]
[[- end -]]

[[- define "nomatron_server_env_block" -]]
[[ template "nomatron_secrets_env_template" . ]]
      env {
[[- if eq (var "secrets_backend" .) "pack_vars" ]]
[[ template "nomatron_server_env_pack_vars" . ]]
[[ template "nomatron_db_url_env_pack_vars" . ]]
[[- else ]]
[[- if ne (var "bootstrap.root_username" .) "" ]]
        NOMATRON_ROOT_USERNAME  = [[ var "bootstrap.root_username" . | quote ]]
[[- end ]]
[[- end ]]
[[ template "env_vars" (var "extra_env_vars" .) ]]
      }
[[- end -]]

[[- define "postgres_task" -]]
    task "postgres" {
      driver = "docker"

      config {
        image = "postgres:[[ var "postgres.image_tag" . ]]"
        ports = ["db"]
      }

      volume_mount {
        volume      = "postgres-data"
        destination = "/var/lib/postgresql/data"
        read_only   = false
      }

      env {
        POSTGRES_DB       = [[ var "postgres.db_name" . | quote ]]
        POSTGRES_USER     = [[ var "postgres.username" . | quote ]]
        POSTGRES_PASSWORD = [[ var "postgres.password" . | quote ]]
        PGDATA            = "/var/lib/postgresql/data"
      }

      resources {
        cpu    = [[ var "postgres.cpu" . ]]
        memory = [[ var "postgres.memory" . ]]
      }

      service {
        name     = [[ var "postgres.service_name" . | quote ]]
        port     = "db"
        provider = [[ var "service_provider" . | quote ]]
        tags     = ["postgres", "nomatron-internal"]
[[- if and (eq (var "database_mode" .) "provision") (gt (var "count" .) 1) ]]
        address_mode = "host"
[[- end ]]

        check {
          name     = "postgres-tcp"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
[[- end -]]

[[- define "nomatron_server_task" -]]
    task "nomatron" {
      driver = [[ if eq (var "runtime" .) "docker" -]]"docker"[[- else -]]"exec"[[- end ]]

[[- if eq (var "runtime" .) "docker" ]]
      config {
        image = "ghcr.io/nomatronio/nomatron-releases/nomatron:[[ var "nomatron_version" . ]]"
        ports = ["http", "grpc", "serf"]
        args  = ["server", "--config", "${NOMAD_TASK_DIR}/config/nomatron.hcl"]
      }
[[- else if eq (var "binary_install_method" .) "artifact" ]]
      artifact {
        source      = "https://github.com/nomatronio/nomatron-releases/releases/download/[[ var "nomatron_version" . ]]/nomatron_[[ trimPrefix "v" (var "nomatron_version" .) ]]_linux_[[ var "binary_arch" . ]].tar.gz"
        destination = "local/bin"
      }

      config {
        command = "[[ template "binary_artifact_command" . ]]"
        args    = ["server", "--config", "${NOMAD_TASK_DIR}/config/nomatron.hcl"]
      }
[[- else ]]
      config {
        command = [[ var "binary_path" . | quote ]]
        args    = ["server", "--config", "${NOMAD_TASK_DIR}/config/nomatron.hcl"]
      }
[[- end ]]

      resources {
        cpu    = [[ var "nomatron_resources.cpu" . ]]
        memory = [[ var "nomatron_resources.memory" . ]]
      }

      template {
        data = <<EOH
server {
  port = [[ var "server.port" . ]]
  api_addr = [[ if ne (var "server.api_addr" .) "" ]][[ var "server.api_addr" . | quote ]][[ else if ne (var "public_hostname" .) "" ]][[ printf "%s://%s" (var "public_scheme" .) (var "public_hostname" .) | quote ]][[ else ]][[ printf "http://127.0.0.1:%v" (var "server.port" .) | quote ]][[ end ]]
  log_level = [[ var "server.log_level" . | quote ]]
  log_format = [[ var "server.log_format" . | quote ]]
  read_header_timeout_seconds = [[ var "server.read_header_timeout_seconds" . ]]
  read_timeout_seconds = [[ var "server.read_timeout_seconds" . ]]
  write_timeout_seconds = [[ var "server.write_timeout_seconds" . ]]
  idle_timeout_seconds = [[ var "server.idle_timeout_seconds" . ]]
[[- if gt (len (var "server.trusted_origins" .)) 0 ]]
  trusted_origins = [[ var "server.trusted_origins" . | toStringList ]]
[[- end ]]
[[- if var "server.tls_enabled" . ]]
  tls_enabled = true
[[- if ne (var "server.tls_cert_file" .) "" ]]
  tls_cert_file = [[ var "server.tls_cert_file" . | quote ]]
[[- end ]]
[[- if ne (var "server.tls_key_file" .) "" ]]
  tls_key_file = [[ var "server.tls_key_file" . | quote ]]
[[- end ]]
[[- if ne (var "server.tls_ca_file" .) "" ]]
  tls_ca_file = [[ var "server.tls_ca_file" . | quote ]]
[[- end ]]
[[- else ]]
  tls_enabled = false
[[- end ]]
}

database {
[[ template "nomatron_database_connection_hcl" . ]]
[[- if gt (var "database.max_open_conns" .) 0 ]]
  max_open_conns = [[ var "database.max_open_conns" . ]]
[[- end ]]
[[- if gt (var "database.max_idle_conns" .) 0 ]]
  max_idle_conns = [[ var "database.max_idle_conns" . ]]
[[- end ]]
[[- if gt (var "database.conn_max_lifetime_seconds" .) 0 ]]
  conn_max_lifetime_seconds = [[ var "database.conn_max_lifetime_seconds" . ]]
[[- end ]]
[[- if gt (var "database.conn_max_idle_time_seconds" .) 0 ]]
  conn_max_idle_time_seconds = [[ var "database.conn_max_idle_time_seconds" . ]]
[[- end ]]
}

serf {
  node_name = "[[- if ne (var "serf.node_name" .) "" -]][[ var "serf.node_name" . ]][[- else -]]{{ env "NOMAD_ALLOC_ID" }}[[- end -]]"
  bind_addr = [[ var "serf.bind_addr" . | quote ]]
  port = [[ var "serf.port" . ]]
[[- if ne (var "serf.advertise_addr" .) "" ]]
  advertise_addr = [[ var "serf.advertise_addr" . | quote ]]
[[- end ]]
[[- if gt (var "count" .) 1 ]]
[[ template "nomatron_serf_encrypt_key_hcl" . ]]
[[- if gt (len (var "serf.retry_join" .)) 0 ]]
  retry_join = [[ var "serf.retry_join" . | toStringList ]]
[[- end ]]
[[- if ne (var "serf.retry_join_interval" .) "" ]]
  retry_join_interval = [[ var "serf.retry_join_interval" . | quote ]]
[[- end ]]
[[- if ge (var "serf.retry_join_max" .) 0 ]]
  retry_join_max = [[ var "serf.retry_join_max" . ]]
[[- end ]]
[[- end ]]
}

operations {
  max_inflight_per_cluster = [[ var "operations.max_inflight_per_cluster" . ]]
}

licensing {
  mode = [[ var "licensing.mode" . | quote ]]
  keygen_base_url = [[ var "licensing.keygen_base_url" . | quote ]]
[[- if ne (var "licensing.relay_base_url" .) "" ]]
  relay_base_url = [[ var "licensing.relay_base_url" . | quote ]]
[[- end ]]
[[- if ne (var "licensing.trusted_account_id" .) "" ]]
  trusted_account_id = [[ var "licensing.trusted_account_id" . | quote ]]
[[- end ]]
[[- if ne (var "licensing.trusted_public_key" .) "" ]]
  trusted_public_key = [[ var "licensing.trusted_public_key" . | quote ]]
[[- end ]]
[[- if gt (len (var "licensing.trusted_product_ids" .)) 0 ]]
  trusted_product_ids = [[ var "licensing.trusted_product_ids" . | toStringList ]]
[[- end ]]
[[- if ne (var "licensing.usage_refresh_every" .) "" ]]
  usage_refresh_every = [[ var "licensing.usage_refresh_every" . | quote ]]
[[- end ]]
}

telemetry {
  enabled = [[ var "telemetry.enabled" . ]]
[[- if ne (var "telemetry.http_proxy" .) "" ]]
  http_proxy = [[ var "telemetry.http_proxy" . | quote ]]
[[- end ]]
[[- if ne (var "telemetry.https_proxy" .) "" ]]
  https_proxy = [[ var "telemetry.https_proxy" . | quote ]]
[[- end ]]
}
EOH
        destination = "local/config/nomatron.hcl"
        change_mode = "restart"
      }

[[ template "nomatron_server_env_block" . ]]
    }
[[- end -]]

[[- define "effective_api_addr" -]]
[[- if ne (var "server.api_addr" .) "" -]]
[[ var "server.api_addr" . ]]
[[- else if ne (var "public_hostname" .) "" -]]
[[ var "public_scheme" . ]]://[[ var "public_hostname" . ]]
[[- else -]]
http://127.0.0.1:[[ var "server.port" . ]]
[[- end -]]
[[- end -]]

[[- define "nomatron_service_block" -]]
      service {
        name     = [[ var "service_name" . | quote ]]
        port     = "http"
        tags     = [[ template "nomatron_service_tags" . ]]
        provider = [[ var "service_provider" . | quote ]]

        check {
          name     = "nomatron-health"
          type     = "http"
          path     = "/api/v1/health?bootstrap=ok"
          interval = "10s"
          timeout  = "3s"
        }
      }
[[- end -]]

## header
[[ define "header" -]]
  datacenters = [[ var "datacenters" . | toStringList ]]
  namespace   = [[ var "namespace" . | quote ]]
  node_pool   = [[ var "node_pool" . | quote ]]
[[- end -]]

##  `clickhouse_password` helper
[[ define "clickhouse_password" ]]
  template {
    destination = "${NOMAD_SECRETS_DIR}/env.vars"
    env         = true
    change_mode = "restart"
    data        = <<EOF
    error_on_missing_key = true
CLICKHOUSE_USER=[[ var "clickhouse_user" . ]]
{{- with nomadVar "[[ var "release_name" .  ]]" }}
CLICKHOUSE_PASSWORD={{ .clickhouse_password }}
{{- end }}
EOF
  }
[[- end -]]

##  `clickhouse_address` helper
[[ define "clickhouse_address" ]]
  template {
    env = true
    data = <<EOH
{{range service "clickhouse-tcp"}}
CLICKHOUSE_PORT={{ .Port }}
CLICKHOUSE_HOST={{ .Address }}
{{end}}
    EOH
    destination = "local/clickhouse.env"
    change_mode   = "restart"
  }
[[- end -]]

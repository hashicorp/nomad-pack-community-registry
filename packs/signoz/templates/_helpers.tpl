[[- /*

# Template Helpers

This file contains Nomad pack template helpers. Any information outside of a
`define` template action is informational and is not rendered, allowing you
to write comments and implementation details about your helper functions here.
Some helper functions are included to get you started.

*/ -]]

[[- /*

## `region` helper

This helper demonstrates conditional element rendering. If your pack specifies
a variable named "region" and it's set, the region line will render otherwise
it won't.

*/ -]]

[[ define "region" -]]
[[- if var "region" . -]]
  region = "[[ var "region" . ]]"
[[- end -]]
[[- end -]]


##  `clickhouse_password` helper
[[ define "clickhouse_password" ]]
  template {
    destination = "${NOMAD_SECRETS_DIR}/env.vars"
    env         = true
    change_mode = "restart"
    data        = <<EOF
CLICKHOUSE_USER     = [[ var "clickhouse_user" . | quote ]]
{{- with nomadVar "nomad/jobs" -}}
CLICKHOUSE_PASSWORD = {{ .clickhouse_password }}
{{- end -}}
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
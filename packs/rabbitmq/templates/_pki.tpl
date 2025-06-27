[[- define "pki" -]]
  [[- if and .vault_enabled .pki_vault_enabled ]]
    [[- template "_pki_vault" . ]]
  [[- else ]]
    [[- template "_pki_artifact" . ]]
  [[- end ]]
[[- end -]]

[[- define "_pki_vault" -]]
      template {
        data        = <<EOH
        {{- $host := printf "common_name=%s.[[ var "pki_vault_domain" . ]]" (env "attr.unique.hostname") -}}
        {{- with secret [[ var "pki_vault_secret_path" . | quote ]] $host -}}
        {{- .Data.issuing_ca -}}
        {{ end }}
        EOH
        destination = "${NOMAD_SECRETS_DIR}/ca.crt"
        change_mode = "restart"
      }

      template {
        data        = <<EOH
        {{- $host := printf "common_name=%s.[[ var "pki_vault_domain" . ]]" (env "attr.unique.hostname") -}}
        {{ with secret [[ var "pki_vault_secret_path" . | quote ]] $host -}}
        {{- .Data.certificate -}}
        {{ end }}
        EOH
        destination = "${NOMAD_SECRETS_DIR}/rabbit.crt"
        change_mode = "restart"
      }

      template {
        data        = <<EOH
        {{- $host := printf "common_name=%s.[[ var "pki_vault_domain" . ]]" (env "attr.unique.hostname") -}}
        {{ with secret [[ var "pki_vault_secret_path" . | quote ]] $host -}}
        {{- .Data.private_key -}}
        {{ end }}
        EOH
        destination = "${NOMAD_SECRETS_DIR}/rabbit.key"
        change_mode = "restart"
      }
[[- end -]]

[[- define "_pki_artifact" ]]
  [[- if var "pki_artifact_ca_cert.enabled" . ]]
      artifact {
        source      = [[ var "pki_artifact_ca_cert.source" . | quote ]]
        destination = "${NOMAD_SECRETS_DIR}/ca.crt"
        [[- if var "pki_artifact_ca_cert.headers" . ]]
        headers     = [[ var "pki_artifact_ca_cert.headers" . | toPrettyJson ]]
        [[- end ]]
        [[- if var "pki_artifact_ca_cert.headers" . ]]
        options     = [[ var "pki_artifact_ca_cert.options" . | toPrettyJson ]]
        [[- end ]]
      }
  [[- end -]]

  [[- if var "pki_artifact_node_cert.enabled" . ]]
      artifact {
        source      = [[ var "pki_artifact_node_cert.source" . | quote ]]
        destination = "${NOMAD_SECRETS_DIR}/rabbit.crt"
        [[- if var "pki_artifact_node_cert.headers" . ]]
        headers     = [[ var "pki_artifact_node_cert.headers" . | toPrettyJson ]]
        [[- end ]]
        [[- if var "pki_artifact_node_cert.headers" . ]]
        options     = [[ var "pki_artifact_node_cert.options" . | toPrettyJson ]]
        [[- end ]]
      }
  [[- end -]]

  [[- if var "pki_artifact_node_cert_key.enabled" . ]]
      artifact {
        source      = [[ var "pki_artifact_node_cert_key.source" . | quote ]]
        destination = "${NOMAD_SECRETS_DIR}/rabbit.key"
        [[- if var "pki_artifact_node_cert_key.headers" . ]]
        headers     = [[ var "pki_artifact_node_cert_key.headers" . | toPrettyJson ]]
        [[- end ]]
        [[- if var "pki_artifact_node_cert_key.headers" . ]]
        options     = [[ var "pki_artifact_node_cert_key.options" . | toPrettyJson ]]
        [[- end ]]
      }
  [[- end -]]
[[- end -]]

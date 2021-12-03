
[[- define "rabbit_env" -]]
      template {
        data        = <<EOH
        [[- if .cookie_vault.enabled ]]
          [[- template "_cookie_vault" .cookie_vault ]]
        [[- else ]]
          [[- template "_cookie_static" .cookie_static ]]
        [[- end ]]

        [[- if .admin_user_vault_enabled ]]
          [[- template "_admin_vault" . ]]
        [[- else]]
          [[- template "_admin_static" . ]]
        [[- end ]]
        EOH
        destination = "${NOMAD_SECRETS_DIR}/rabbit.env"
        env         = true
      }
[[- end -]]


[[- define "_cookie_vault" ]]
        {{ with secret [[ .path | quote ]] }}
        RABBITMQ_ERLANG_COOKIE="{{ .Data.data.[[ .key ]] }}"
        {{ end }}
[[- end -]]

[[- define "_cookie_static" ]]
        RABBITMQ_ERLANG_COOKIE=[[ . | quote ]]
[[- end -]]


[[- define "_admin_vault" ]]
        {{ with secret [[ .admin_user_vault_path | quote ]] }}
        RABBITMQ_DEFAULT_USER={{ .Data.data.[[ .admin_user_vault_username_key ]] }}
        RABBITMQ_DEFAULT_PASS={{ .Data.data.[[ .admin_user_vault_password_key]] }}
        {{ end }}
[[- end -]]

[[- define "_admin_static" ]]
        RABBITMQ_DEFAULT_USER=[[ .admin_user_static_username | quote ]]
        RABBITMQ_DEFAULT_PASS=[[ .admin_user_static_password | quote ]]
[[- end -]]

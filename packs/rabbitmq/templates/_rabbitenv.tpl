
[[- define "rabbit_env" -]]
      template {
        data        = <<EOH
    [[- if var "cookie_vault.enabled" . ]]
        {{ with secret [[ var "cookie_vault.path" . | quote ]] }}
        RABBITMQ_ERLANG_COOKIE="{{ .Data.data.[[ var "cookie_vault.key" . ]] }}"
        {{ end }}
    [[- else ]]
        RABBITMQ_ERLANG_COOKIE=[[ var "cookie_static" . | quote ]]
    [[- end ]]

    [[- if var "admin_user_vault_enabled" . ]]
        {{ with secret [[ var "admin_user_vault_path" . | quote ]] }}
        RABBITMQ_DEFAULT_USER={{ .Data.data.[[ var "admin_user_vault_username_key" . ]] }}
        RABBITMQ_DEFAULT_PASS={{ .Data.data.[[ var "admin_user_vault_password_key" . ]] }}
        {{ end }}
    [[- else]]
        RABBITMQ_DEFAULT_USER=[[ var "admin_user_static_username" . | quote ]]
        RABBITMQ_DEFAULT_PASS=[[ var "admin_user_static_password" . | quote ]]
    [[- end ]]
        EOH
        destination = "${NOMAD_SECRETS_DIR}/rabbit.env"
        env         = true
      }
[[- end -]]

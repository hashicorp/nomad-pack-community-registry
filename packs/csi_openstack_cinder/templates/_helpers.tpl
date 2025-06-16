// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq (var "job_name" .) "" -]]
[[- meta "pack.name" . | quote -]]
[[- else -]]
[[- var "job_name" . | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq (var "region" .) "") -]]
region = [[ var "region" . | quote]]
[[- end -]]
[[- end -]]

[[- define "constraints" -]]
[[- range $idx, $constraint := . ]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    [[ if $constraint.operator -]]
    operator  = [[ $constraint.operator | quote ]]
    [[ end -]]
    value     = [[ $constraint.value | quote ]]
  }
[[- end ]]
[[- end -]]

[[- define "vault_config" -]]
    [[ if var "vault_config.enabled" . ]]
    vault {
      [[- if var "vault_config.enabled" . ]]
      policies      = [ [[- range $idx, $pol := var "vault_config.policies" . -]][[if $idx]], [[end]][[ $pol | quote ]][[- end -]] ]
      [[- end ]]
      [[- if var "vault_config.change_mode" . ]]
      change_mode   = [[ var "vault_config.change_mode" . ]]
      [[- end ]]
      [[- if var "vault_config.change_signal" . ]]
      change_signal = [[ var "vault_config.change_signal" . ]]
      [[- end ]]
      [[- if not ( eq (var "vault_config.env" .) nil ) ]]
      env           = [[ var "vault_config.env" . ]]
      [[- end ]]
      [[- if var "vault_config.namespace" . ]]
      namespace     = [[ var "vault_config.namespace" . ]]
      [[- end ]]
    }
    [[ end ]]
[[- end -]]

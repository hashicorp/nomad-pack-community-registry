// allow nomad-pack to set the job name
[[- define "full_job_name" -]]
[[- if eq .opentelemetry_collector.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .opentelemetry_collector.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified
[[- define "region" -]]
[[- if not (eq .opentelemetry_collector.region "") -]]
region = [[ .opentelemetry_collector.region | quote]]
[[- end -]]
[[- end -]]

// generate the vault task config block if enabled
[[- define "vault_config" -]]
    [[ if .opentelemetry_collector.vault_config.enabled ]]
    vault {
      [[- if .opentelemetry_collector.vault_config.policies ]]
      policies      = [[ .opentelemetry_collector.vault_config.policies | toPrettyJson ]]
      [[- end ]]
      [[- if .opentelemetry_collector.vault_config.change_mode ]]
      change_mode   = [[ .opentelemetry_collector.vault_config.change_mode ]]
      [[- end ]]
      [[- if .opentelemetry_collector.vault_config.change_signal ]]
      change_signal = [[ .opentelemetry_collector.vault_config.change_signal ]]
      [[- end ]]
      [[- if .opentelemetry_collector.vault_config.env ]]
      env           = [[ .opentelemetry_collector.vault_config.env ]]
      [[- end ]]
      [[- if .opentelemetry_collector.vault_config.namespace ]]
      namespace     = [[ .opentelemetry_collector.vault_config.namespace ]]
      [[- end ]]
    }
    [[ end ]]
[[- end -]]

[[- define "traefik_service_tags" -]]
  [[- if (not .traefik_config.enabled) -]]
    [[ .service.service_tags | toStringList ]]
  [[- else -]]
    [[- if (eq .service.service_port_label "otlp") -]]
      [[ concat .service.service_tags (list
          "traefik.tcp.routers.otel-collector-grpc.rule=HostSNI(`*`)"
          "traefik.tcp.routers.otel-collector-grpc.entrypoints=grpc"
          "traefik.enable=true"
        ) | toPrettyJson
      ]]
    [[- else if (eq .service.service_port_label "otlphttp") -]]
      [[ concat .service.service_tags (list
          (printf "traefik.http.routers.otel-collector-http.rule=Host(`%s`)" .traefik_config.http_host)
          "traefik.http.routers.otel-collector-http.entrypoints=web"
          "traefik.http.routers.otel-collector-http.tls=false"
          "traefik.enable=true"
        ) | toPrettyJson
      ]]
    [[- else -]]
      [[ .service.service_tags | toStringList ]]
    [[- end -]]
  [[- end -]]
[[- end -]]

// the default map configures the hostmetrics receiver to look at `/hostfs` mounts for system stats
// it is merged with .task_config.env which will take precedence in the merge
// in the event of a conflict
[[- define "env_vars" -]]
[[- $defaultEnv := (dict
  "HOST_PROC" "/hostfs/proc"
  "HOST_SYS" "/hostfs/sys"
  "HOST_ETC" "/hostfs/etc"
  "HOST_VAR" "/hostfs/var"
  "HOST_RUN" "/hostfs/run"
  "HOST_DEV" "/hostfs/dev"
) -]]
    env {
      [[- range $key, $value := mergeOverwrite $defaultEnv .opentelemetry_collector.task_config.env -]]
      [[- if $key ]]
        [[ $key ]] = [[ $value | quote ]]
      [[- end ]]
      [[- end ]]
    }
[[- end -]]

// render any additional templates for the task
[[- define "additional_templates" -]]
  [[- range $tmpl := .opentelemetry_collector.additional_templates ]]
      template {
        destination = [[ $tmpl.destination | quote ]]
        data = <<EOH
[[ $tmpl.data -]]
EOH
        [[- if $tmpl.change_mode ]]
        change_mode = [[ $tmpl.change_mode | quote ]]
        [[- end ]]
        [[- if $tmpl.change_signal ]]
        change_signal = [[ $tmpl.change_signal | quote ]]
        [[- end ]]
        [[- if $tmpl.env ]]
        env = [[ $tmpl.env ]]
        [[- end ]]
        [[- if $tmpl.perms ]]
        perms = [[ $tmpl.perms | quote ]]
        [[- end ]]
      }
  [[- end ]]
[[- end ]]

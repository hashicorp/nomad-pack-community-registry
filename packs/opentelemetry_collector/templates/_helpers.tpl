// allow nomad-pack to set the job name

[[- define "job_name" -]]
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

[[- define "network_ports" -]]
[[- range .opentelemetry_collector.network_ports ]]
port [[ .name | quote ]] {
  to = [[ .port ]]
}
[[ end -]]
[[- end -]]

[[- define "container_ports" -]]
[ [[- range .opentelemetry_collector.network_ports ]] [[ .name | quote ]],[[ end ]] ]
[[- end -]]


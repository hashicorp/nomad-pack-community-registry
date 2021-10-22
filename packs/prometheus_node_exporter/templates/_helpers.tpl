// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .prometheus_node_exporter.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .prometheus_node_exporter.job_name | quote -]]
[[- end -]]
[[- end -]]

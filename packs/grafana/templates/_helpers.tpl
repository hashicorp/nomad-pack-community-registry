// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .grafana.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .grafana.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .grafana.region "") -]]
region = [[ .grafana.region | quote]]
[[- end -]]
[[- end -]]

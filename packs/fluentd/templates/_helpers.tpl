// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .fluentd.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .fluentd.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .fluentd.region "") -]]
region = [[ .fluentd.region | quote]]
[[- end -]]
[[- end -]]

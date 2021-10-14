// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .loki.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .loki.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .loki.region "") -]]
region = [[ .loki.region | quote]]
[[- end -]]
[[- end -]]

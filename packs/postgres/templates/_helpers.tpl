// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .postgres.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .postgres.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .postgres.region "") -]]
region = [[ .postgres.region | quote]]
[[- end -]]
[[- end -]]

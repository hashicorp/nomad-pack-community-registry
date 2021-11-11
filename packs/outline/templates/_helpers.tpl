// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .outline.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .outline.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .outline.region "") -]]
region = [[ .outline.region | quote]]
[[- end -]]
[[- end -]]

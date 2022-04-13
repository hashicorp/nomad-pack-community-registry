// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .boundary.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .boundary.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .boundary.region "") -]]
region = [[ .boundary.region | quote]]
[[- end -]]
[[- end -]]

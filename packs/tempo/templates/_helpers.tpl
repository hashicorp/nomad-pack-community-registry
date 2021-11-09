// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .tempo.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .tempo.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .tempo.region "") -]]
region = [[ .tempo.region | quote]]
[[- end -]]
[[- end -]]

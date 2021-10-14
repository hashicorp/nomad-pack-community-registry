// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .fabio.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .fabio.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .fabio.region "") -]]
region = [[ .fabio.region | quote]]
[[- end -]]
[[- end -]]

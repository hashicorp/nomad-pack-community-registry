// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .alertmanager.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .alertmanager.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .alertmanager.region "") -]]
region = [[ .alertmanager.region | quote]]
[[- end -]]
[[- end -]]

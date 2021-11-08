// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .ctfd.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .ctfd.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .ctfd.region "") -]]
region = [[ .ctfd.region | quote]]
[[- end -]]
[[- end -]]

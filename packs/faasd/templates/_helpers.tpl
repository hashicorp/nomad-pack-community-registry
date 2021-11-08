// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .faasd.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .faasd.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .faasd.region "") -]]
region = [[ .faasd.region | quote]]
[[- end -]]
[[- end -]]

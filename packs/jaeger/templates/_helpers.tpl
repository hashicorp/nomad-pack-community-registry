// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .jaeger.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .jaeger.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .jaeger.region "") -]]
region = [[ .jaeger.region | quote]]
[[- end -]]
[[- end -]]

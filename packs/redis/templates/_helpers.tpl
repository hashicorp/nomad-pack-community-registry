// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .redis.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .redis.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .redis.region "") -]]
region = [[ .redis.region | quote]]
[[- end -]]
[[- end -]]

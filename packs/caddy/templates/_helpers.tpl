// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .caddy.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .caddy.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .caddy.region "") -]]
region = [[ .caddy.region | quote]]
[[- end -]]
[[- end -]]

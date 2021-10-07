// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .traefik.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .traefik.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .traefik.region "") -]]
region = [[ .traefik.region | quote]]
[[- end -]]
[[- end -]]

// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .haproxy.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .haproxy.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .haproxy.region "") -]]
region = [[ .haproxy.region | quote]]
[[- end -]]
[[- end -]]

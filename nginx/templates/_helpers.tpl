// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .nginx.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .nginx.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if eq .nginx.region "" -]]
[[- else -]]
region = [[ .nginx.region | quote]]
[[- end -]]
[[- end -]]

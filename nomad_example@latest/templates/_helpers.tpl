// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .nomad_example.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .nomad_example.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if eq .nomad_example.region "" -]]
[[- else -]]
region = [[ .nomad_example.region | quote]]
[[- end -]]
[[- end -]]
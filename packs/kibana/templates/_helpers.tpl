// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .kibana.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .kibana.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .kibana.region "") -]]
region = [[ .kibana.region | quote]]
[[- end -]]
[[- end -]]

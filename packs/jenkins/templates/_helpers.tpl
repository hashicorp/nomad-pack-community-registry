// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .jenkins.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .jenkins.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .jenkins.region "") -]]
region = [[ .jenkins.region | quote]]
[[- end -]]
[[- end -]]

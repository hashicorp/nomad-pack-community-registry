// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .sonarqube.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .sonarqube.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .sonarqube.region "") -]]
region = [[ .sonarqube.region | quote]]
[[- end -]]
[[- end -]]
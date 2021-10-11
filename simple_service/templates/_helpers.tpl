// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .hello_world.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .hello_world.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .hello_world.region "") -]]
region = [[ .hello_world.region | quote]]
[[- end -]]
[[- end -]]

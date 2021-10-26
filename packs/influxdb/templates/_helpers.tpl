// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .influxdb.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .influxdb.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .influxdb.region "") -]]
region = [[ .influxdb.region | quote]]
[[- end -]]
[[- end -]]

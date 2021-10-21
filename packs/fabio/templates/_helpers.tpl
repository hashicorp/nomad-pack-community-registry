// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .fabio.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .fabio.job_name | quote -]]
[[- end -]]
[[- end -]]

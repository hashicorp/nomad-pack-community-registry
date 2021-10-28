// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .nomad_ingress_nginx.job_name "" -]]
[[- .nomad_pack.pack.name -]]
[[- else -]]
[[- .nomad_ingress_nginx.job_name -]]
[[- end -]]
[[- end -]]

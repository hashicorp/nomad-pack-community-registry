// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .chaotic_ngine.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .chaotic_ngine.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .chaotic_ngine.region "") -]]
region = [[ .chaotic_ngine.region | quote]]
[[- end -]]
[[- end -]]

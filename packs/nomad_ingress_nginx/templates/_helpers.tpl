// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq (var "job_name" .) "" -]]
[[- meta "pack.name" . -]]
[[- else -]]
[[- var "job_name" . -]]
[[- end -]]
[[- end -]]

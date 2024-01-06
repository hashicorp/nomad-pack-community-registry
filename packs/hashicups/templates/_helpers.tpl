// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[ meta "pack.name" . | quote ]]
[[- end -]]

// only deploys to a region if specified

[[ define "region" -]]
[[- if var "region" . -]]
region = [[ var "region" . | quote ]]
[[- end -]]
[[- end -]]
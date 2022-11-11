// allow nomad-pack to set the job name
[[ define "job_name" ]]
[[- if eq .backstage.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .backstage.job_name | quote -]]
[[- end ]]
[[- end ]]

// only deploys to a region if specified
[[ define "region" -]]
[[- if not (eq .backstage.region "") -]]
  region = [[ .backstage.region | quote]]
[[- end -]]
[[- end -]]

// allow nomad-pack to set the job name

// only deploys to a region if specified
[[ define "region" -]]
[[- if not (eq .backstage.region "") -]]
  region = [[ .backstage.region | quote]]
[[- end -]]
[[- end -]]

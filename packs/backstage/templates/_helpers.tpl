// allow nomad-pack to set the job name

// only deploys to a region if specified
[[ define "region" -]]
[[- if not (eq (var "region" .) "") -]]
  region = [[ var "region" . | quote]]
[[- end -]]
[[- end -]]

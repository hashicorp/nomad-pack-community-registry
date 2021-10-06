{{- if not eq .fabio.region "" -}}
// only deploys to a region if specified
region = [[ .fabio.region | quote]]
{{- end -}}

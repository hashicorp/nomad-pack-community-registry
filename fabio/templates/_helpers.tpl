{{- define "fabio.job_name" -}}
{{- if eq .fabio.job_name "" -}}
// allow nomad-pack to set the job name
{{- .nomad_pack.pack.name | quote -}}
{{- else -}}
{{- .fabio.job_name | quote -}}
{{- end -}}
{{- end -}}

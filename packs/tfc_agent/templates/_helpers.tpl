// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq (var "job_name" .) "" -]]
[[- meta "pack.name" . | quote -]]
[[- else -]]
[[- var "job_name" . | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq (var "region" .) "") -]]
region = [[ var "region" . | quote]]
[[- end -]]
[[- end -]]

// format the list of datacenters

[[- define "datacenters" -]]
datacenters = [[ var "datacenters" . | toStringList ]]
[[- end -]]

// only specify a namespace when given
[[- define "namespace" -]]
[[- if ne (var "namespace" .) "" -]]
namespace = [[ var "namespace" . | quote ]]
[[- end -]]
[[- end -]]

// only sets the OTLP cert file when appropriate

[[- define "otlp_cert_file" -]]
[[- if eq (var "agent_otlp_cert" .) "" -]]
""
[[- else -]]
"/home/tfc-agent/certs/otlp.pem"
[[- end -]]
[[- end -]]

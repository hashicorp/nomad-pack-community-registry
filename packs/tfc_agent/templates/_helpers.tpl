// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .tfc_agent.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .tfc_agent.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .tfc_agent.region "") -]]
region = [[ .tfc_agent.region | quote]]
[[- end -]]
[[- end -]]

// format the list of datacenters

[[- define "datacenters" -]]
datacenters = [[ .tfc_agent.datacenters | toStringList ]]
[[- end -]]

// only specify a namespace when given
[[- define "namespace" -]]
[[- if ne .tfc_agent.namespace "" -]]
namespace = [[ .tfc_agent.namespace | quote ]]
[[- end -]]
[[- end -]]

// only sets the OTLP cert file when appropriate

[[- define "otlp_cert_file" -]]
[[- if eq .tfc_agent.agent_otlp_cert "" -]]
""
[[- else -]]
"/home/tfc-agent/certs/otlp.pem"
[[- end -]]
[[- end -]]

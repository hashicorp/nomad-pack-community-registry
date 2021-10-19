[[- define "otlp_cert_file" -]]
[[- if eq .tfc_agent.agent_otlp_cert "" -]]
""
[[- else -]]
"/home/tfc-agent/certs/otlp.pem"
[[- end -]]
[[- end -]]

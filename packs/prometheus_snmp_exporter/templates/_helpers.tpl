// Job name
[[- define "full_job_name" -]]
[[- if eq .prometheus_snmp_exporter.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .prometheus_snmp_exporter.job_name | quote -]]
[[- end -]]
[[- end -]]

// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .promtail.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .promtail.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .promtail.region "") -]]
region = [[ .promtail.region | quote]]
[[- end -]]
[[- end -]]

// Use provided config file if defined, else render a default
[[- define "promtail_config" -]]
[[- if (eq .promtail.config_file "") -]]
server:
  http_listen_port: [[ .promtail.http_port ]]
  log_level: [[ .promtail.log_level ]]

positions:
  filename: /tmp/positions.yaml

clients:
  [[ range $idx, $url := .promtail.client_urls ]][[if $idx]]  [[end]][[ $url | printf "- url: %s\n" ]][[ end ]]
scrape_configs:
- job_name: journal
  journal:
    max_age: [[ .promtail.journal_max_age ]]
    json: false
    labels:
      job: systemd-journal
  relabel_configs:
  - source_labels:
    - __journal__systemd_unit
    target_label: systemd_unit
  - source_labels:
    - __journal__hostname
    target_label: nodename
  - source_labels:
    - __journal_syslog_identifier
    target_label: syslog_identifier
[[- else -]]
[[ $config := .promtail.config_file ]][[ fileContents $config ]]
[[- end -]]
[[- end -]]
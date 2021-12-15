Prometheus Consul Exporter successfully deployed.

[[- if .prometheus_consul_exporter.consul_exporter_task_services ]]

The following example Prometheus config yaml can be used to scrape the Consul
exporter. The `consul_sd_configs.server` entry will need updating to match your
environment and deployment.

- job_name: "consul_exporter"
  metrics_path: "/metrics"
  consul_sd_configs:
    - server: "consul.example.com:8500"
      services:
        - [[ (index .prometheus_consul_exporter.consul_exporter_task_services 0).service_name | quote ]]
[[- end ]]

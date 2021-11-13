# This example configures the OTel Collector to run in privledged mode in order to gather host metrics
# and ship's the traces and metrics to Honeycomb.io via OTLP
privileged_mode = true

resources = {
  cpu    = 1024
  memory = 2048
}

task_config = {
  image   = "myorg/opentelemetry-collector"
  version = "0.38.0"
  env = {
    OTEL_METRICS_INTERVAL     = "10s"
    HONEYCOMB_DATASET         = "production-traces"
    HONEYCOMB_METRICS_DATASET = "production-metrics"
  }
}

vault_config = {
  enabled  = true
  policies = ["otel-collector"]
}

additional_templates = [{
  env         = true
  destination = "secrets/file.env"
  change_mode = "restart"
  data        = <<EOH
{{ with secret "kv/data/applications/otel-collector" }}
{{ range $k, $v := .Data.data }}
{{ $k }}={{ $v | toJSON }}
{{ end }}{{ end }}
EOH
}]

config_yaml = <<EOH
---
receivers:
  hostmetrics:
    collection_interval: "$OTEL_METRICS_INTERVAL"
    scrapers:
      cpu:
      disk:
      filesystem:
      load:
      memory:
      network:
      paging:
  otlp:
    protocols:
      grpc:
      http:
  jaeger:
    protocols:
      grpc:
      thrift_http:
  prometheus:
    config:
      scrape_configs:
        # grab metrics from this collector instance
        - job_name: "otel-collector"
          scrape_interval: "$OTEL_METRICS_INTERVAL"
          static_configs:
            - targets: ["localhost:8888"]

processors:
  timestamp:
    round_to_nearest: 1s
  batch:
  memory_limiter:
    check_interval: 1s
    limit_mib: 1536

extensions:
  health_check: {}
  memory_ballast:
    size_in_percentage: 35
  zpages: {}

exporters:
  otlp:
    endpoint: "api.honeycomb.io:443"
    headers:
      "x-honeycomb-team": "$HONEYCOMB_API_KEY"
      "x-honeycomb-dataset": "$HONEYCOMB_DATASET"
  otlp/metrics:
    endpoint: "api.honeycomb.io:443"
    headers:
      "x-honeycomb-team": "$HONEYCOMB_API_KEY"
      "x-honeycomb-dataset": "$HONEYCOMB_METRICS_DATASET"
  logging:
    loglevel: warn

service:
  extensions: [health_check, zpages]
  pipelines:
    traces:
      receivers: [otlp, jaeger]
      processors: [memory_limiter, batch]
      exporters: [otlp, logging]
    metrics:
      receivers: [hostmetrics, otlp/metrics, prometheus]
      processors: [memory_limiter, timestamp, batch]
      exporters: [otlp, logging]
EOH

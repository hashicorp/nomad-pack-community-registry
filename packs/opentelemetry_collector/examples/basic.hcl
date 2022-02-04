# This example configures a basic OTel Collector to receive traces over OTLP or Jager, and ships them
# to a OTLP endpoint

job_type = "service"

task_config = {
  image   = "otel/opentelemetry-collector-contrib"
  version = "0.38.0"
  env = {
    MY_API_KEY = "not-so-secret"
  }
}

config_yaml = <<EOH
---
receivers:
  otlp:
    protocols:
      grpc:
  jaeger:
    protocols:
      grpc:

processors:
  batch:
  memory_limiter:
    check_interval: 1s
    limit_mib: 384

extensions:
  health_check: {}

exporters:
  otlp:
    endpoint: "otlp.mycorp.tld:4317"
    headers:
      "x-api-key": "$MY_API_KEY"
  logging:
    loglevel: warn

service:
  extensions: [health_check]
  pipelines:
    traces:
      receivers: [otlp, jaeger]
      processors: [memory_limiter, batch]
      exporters: [otlp, logging]
EOH

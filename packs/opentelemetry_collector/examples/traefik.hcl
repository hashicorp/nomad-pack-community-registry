# This example configures a basic OTel Collector with Traefik.
# It receives traces over OTLP, and ships them to Lighstep, Honeycomb, and Datadog
# API keys/tokens for each Observability platform are retrieved from HashiCorp Vault.
# NOTE: You need to have accounts in each of these platforms in order for this to work.

job_type = "service"

job_name = "otel-collector"

task_config = {
  image   = "otel/opentelemetry-collector-contrib"
  version = "0.50.0"
  env = {
    HONEYCOMB_DATASET    = "my-hny-dataset"
    DATADOG_SERVICE_NAME = "my-dd-service"
    DATADOG_TAG_NAME     = "env:local_dev_env"
  }
}


# Override vault config in vars file
vault_config = {
  enabled  = true
  policies = ["otel"]
}

# Traefik config
traefik_config = {
  enabled   = true
  http_host = "otel-collector-http.localhost"
}

config_yaml = <<EOH
---
receivers:
  otlp:
    protocols:
      grpc:
      http:

processors:
  batch:
    timeout: 10s
  memory_limiter:
    limit_mib: 1536
    spike_limit_mib: 512
    check_interval: 5s

exporters:
  logging:
    logLevel: debug

  otlp/hc:
    endpoint: "api.honeycomb.io:443"
    headers:
      "x-honeycomb-team": "{{ with secret "kv/data/otel/o11y/honeycomb" }}{{ .Data.data.api_key }}{{ end }}"
      "x-honeycomb-dataset": "$HONEYCOMB_DATASET"
  otlp/ls:
    endpoint: ingest.lightstep.com:443
    headers:
      "lightstep-access-token": "{{ with secret "kv/data/otel/o11y/lightstep" }}{{ .Data.data.api_key }}{{ end }}"

  datadog:
    service: $DATADOG_SERVICE_NAME
    tags:
      - $DATADOG_TAG_NAME
    api:
      key: "{{ with secret "kv/data/otel/o11y/datadog" }}{{ .Data.data.api_key }}{{ end }}"
      site: datadoghq.com

service:
  pipelines:
    traces:
      receivers: [otlp]
      exporters: [logging, otlp/ls, otlp/hc, datadog]
EOH

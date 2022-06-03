# This example configures a basic OTel Collector with Traefik.
# It receives traces over OTLP, and ships them to Lighstep, Honeycomb, and Datadog
# API keys/tokens for each Observability platform are retrieved from HashiCorp Vault.
# NOTE: You need to have accounts in each of these platforms in order for this to work.

# To run this example, you'll need to run this pack and the Traefik pack as follows, assuming
# that you are starting from the repo root:
# $ nomad-pack run traefik -f packs/opentelemetry_collector/examples/traefik_vars.hcl
# $ nomad-pack run opentelemetry_collector -f packs/opentelemetry_collector/examples/with_traefik.hcl

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

# Override default network_config to set network mode to host
network_config = {
  mode = "host"
  ports = {
    "otlp"               = 4317
    "otlphttp"           = 4318
    "metrics"            = 8888
    "zipkin"             = 9411
    "healthcheck"        = 13133
    "jaeger-grpc"        = 14250
    "jaeger-thrift-http" = 14268
    "zpages"             = 55679
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

extensions:
  health_check:

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
  extensions: [health_check]
  pipelines:
    traces:
      receivers: [otlp]
      exporters: [logging, otlp/ls, otlp/hc, datadog]
EOH

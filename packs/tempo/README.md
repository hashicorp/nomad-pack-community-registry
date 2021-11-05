# tempo

Grafana [Tempo](https://grafana.com/oss/tempo/) is an open source, easy-to-use and high-scale distributed tracing backend. Tempo is cost-efficient, requiring only object storage to operate, and is deeply integrated with Grafana, Prometheus, and Loki. Tempo can be used with any of the open source tracing protocols, including Jaeger, Zipkin, and OpenTelemetry.

This pack deploys a single instance of a tempo application using the `grafana/tempo` Docker image and Consul Service named "tempo".

## Dependencies

This pack requires Linux clients to run properly.

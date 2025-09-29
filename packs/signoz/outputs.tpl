SigNoz Observability Platform Successfully Deployed!!

Your complete SigNoz observability stack is now running on Nomad with the following components:

**SigNoz Platform**
   • Web UI: http://<nomad-client-ip>:8080

**OpenTelemetry Collector**
   • OTLP gRPC: http://<nomad-client-ip>:4317
   • OTLP HTTP: http://<nomad-client-ip>:4318
   • Metrics: http://<nomad-client-ip>:8888/metrics
   • Health: http://<nomad-client-ip>:13133

**Service Discovery (Consul)**
   • clickhouse.service.consul - ClickHouse TCP and HTTP service
   • zookeeper.service.consul - ZooKeeper coordination
   • signoz.service.consul - SigNoz main service
   • signoz-otel-collector.service.consul - OTEL Collector

**Next Steps:**
1. Access the SigNoz web interface at http://<nomad-client-ip>:8080
2. Configure your applications to send telemetry data to the OTEL Collector
3. Monitor your services through the SigNoz dashboard
4. Check job status: `nomad job status signoz-*`

**Documentation:**
   • SigNoz: https://signoz.io/docs/
   • OpenTelemetry: https://opentelemetry.io/docs/
   • ClickHouse: https://clickhouse.com/docs/

Happy Observing!

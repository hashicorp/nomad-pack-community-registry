# alertmanager

The [Alertmanager](hhttps://github.com/prometheus/alertmanager) handles alerts sent by client applications such as the Prometheus server. It takes care of deduplicating, grouping, and routing them to the correct receiver integrations such as email, PagerDuty, or OpsGenie. It also takes care of silencing and inhibition of alerts.

This pack deploys a single instance of a alertmanager application using the `prom/alertmanager` Docker image and Consul Service named "alertmanager".

## Dependencies

This pack requires Linux clients to run properly.

app {
  url    = "https://github.com/prometheus/alertmanager"
  author = "Prometheus Maintainers"
}

pack {
  name        = "alertmanager"
  description = "The Alertmanager handles alerts sent by client applications such as the Prometheus server. It takes care of deduplicating, grouping, and routing them to the correct receiver integrations such as email, PagerDuty, or OpsGenie. It also takes care of silencing and inhibition of alerts."
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/alertmanager"
  version     = "0.0.1"
}

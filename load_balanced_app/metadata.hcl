app {
  url = "https://learn.hashicorp.com/collections/nomad/load-balancing"
  author = "HashiCorp"
}

pack {
  name = "load_balanced_app"
  type = "job"
  description = "This pack contains two jobs. An application and a load balancer. The load balancer requires Consul to work properly."
}

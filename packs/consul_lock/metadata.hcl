app {
  url    = "https://learn.hashicorp.com/tutorials/consul/application-leader-elections"
  author = "HashiCorp, Inc."
}

pack {
  name        = "consul_lock"
  description = "A pack demonstrating the use of Consul session locks for ensuring that only a single allocation of a job is running at a time."
  url         = "https://github.com/hashicorp/nomad-pack-community-registry/consul_lock"
  version     = "0.1.0"
}

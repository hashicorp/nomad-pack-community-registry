app {
  url = "https://learn.hashicorp.com/tutorials/nomad/get-started-run?in=nomad/get-started"
}

pack {
  name = "hello_world"
  description = "This deploys a simple applicaton as a service with an optional associated Nomad service."
  version = "0.0.2"
}

integration {
  identifier = "nomad/hashicorp/hello-world"
  name       = "Hello World"
}

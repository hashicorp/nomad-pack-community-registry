job "redis" {

  region = "global"
  datacenters = ["dc1"]
  namespace   = "default"
  type        = "system"
  
  
  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  group "redis" {
    network {
      mode = "bridge"
      port "http" {
        to = 6379
      }
    }

    task "redis" {
      driver = "docker"
      config {
        image = "redis:latest"
        ports = ["http"]
      }
      resources {
        cpu    = 200
        memory = 256
      }
    }
  }
}

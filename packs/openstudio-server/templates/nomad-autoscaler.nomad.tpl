[[ if var "nomad_autoscaler_enabled" . ]]
job "[[ var "job_name" . ]]-autoscaler" {
  region      = "[[ var "region" . ]]"
  datacenters = [[ var "datacenters" . | toJson ]]
  namespace   = "[[ var "nomad_namespace" . ]]"
  type        = "service"

  group "autoscaler" {
    count = 1

    network {
      port "http" {
        to = 8080
      }
    }

    task "autoscaler" {
      driver = "docker"

      config {
        image   = "hashicorp/nomad-autoscaler:0.4.7"
        command = "nomad-autoscaler"
        args    = ["agent", "-config", "local/autoscaler.hcl"]
      }

      template {
        destination = "local/autoscaler.hcl"
        data        = <<EOH
nomad {
  address = "http://nomad.service.consul:4646"
}

apm "nomad-apm" {
  driver = "nomad-apm"
}

# Optional Prometheus APM source:
# apm "prometheus" {
#   driver = "prometheus"
#   config = {
#     address = "http://prometheus:9090"
#   }
# }

strategy "target-value" {
  driver = "target-value"
}
EOH
      }

      resources {
        cpu    = 200
        memory = 128
      }

      service {
        name     = "nomad-autoscaler"
        port     = "http"
        provider = "consul"

        check {
          name     = "nomad-autoscaler-tcp"
          type     = "tcp"
          interval = "30s"
          timeout  = "5s"
        }
      }
    }
  }
}
[[ end ]]

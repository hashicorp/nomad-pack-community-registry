[[- if eq (var "load_balancer_mode" .) "traefik" ]]
job [[ var "traefik.job_name" . | quote ]] {
  [[ template "region" . ]]
  datacenters = [[ var "datacenters" . | toStringList ]]
  namespace   = [[ var "namespace" . | quote ]]
  node_pool   = [[ var "node_pool" . | quote ]]
  type        = "system"

  group "traefik" {
    network {
      mode = [[ var "traefik.network_mode" . | quote ]]
      port "http" {
        static = [[ var "traefik.http_port" . ]]
      }
      port "admin" {
        static = [[ var "traefik.admin_port" . ]]
      }
    }

    task "traefik" {
      driver = "docker"

      config {
        image        = "traefik:[[ var "traefik.version" . ]]"
        network_mode = [[ var "traefik.network_mode" . | quote ]]
        ports        = ["http", "admin"]
        args = [
          "--api.insecure=true",
          "--providers.nomad=true",
          "--providers.nomad.endpoint.address=http://127.0.0.1:4646",
          "--entrypoints.web.address=:[[ var "traefik.http_port" . ]]",
        ]
      }

      resources {
        cpu    = [[ var "traefik.cpu" . ]]
        memory = [[ var "traefik.memory" . ]]
      }

      service {
        name     = "traefik"
        port     = "http"
        provider = [[ var "service_provider" . | quote ]]
        tags     = ["traefik", "load-balancer"]

        check {
          name     = "traefik-admin"
          type     = "http"
          path     = "/ping"
          port     = "admin"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
[[- end ]]

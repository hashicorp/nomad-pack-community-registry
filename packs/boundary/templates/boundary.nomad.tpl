job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .boundary.datacenters | toPrettyJson ]]
  group "boundary_controller" {
    count = [[ .boundary.controller_count ]]
    network {
      #Clients must have access to the Controller's port (default 9200)
      port "controller" {
        to = 9200
      }
      #Workers must have access to the Controller's port (default 9201)
      port "worker" {
        to = 9201
      }
      #Clients must have access to the Worker's port (default 9202)
      port "comm" {
        to = 9202
      }
    }

    task "boundary" {
      driver = "docker"

      config {
        image = "hashicorp/boundary"
      }

      ##TODO: Interpolate Postgres address
      ##TODO: Clean up pulling creds from Vault
      ##TODO: Use service mesh instead of service discovery for Postgres address
      template {
        env         = true
        destination = "secrets/config.env"
        data        = <<EOF
BOUNDARY_POSTGRES_URL=postgresql://{{ with secret "ops/postgres" }}{{ .Data.data.username }}:{{ .Data.data.password }}{{ end }}@{{ range service "postgres" }}{{ .Address }}:{{ .Port }}{{ end }}/postgres?sslmode=disable
EOF
      }
    }
  }
}

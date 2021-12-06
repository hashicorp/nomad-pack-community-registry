job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .postgres.datacenters ]]
  group "postgres" {
    network {
      port "postgres" {
        to = 5432
      }
    }
    task "postgres" {
      driver = "docker"
      
      config {
        image = "postgres"
      }

      template {
        env         = true
        destination = "secrets/config.env"
        data        = <<EOF
POSTGRES_USER=[[ .postgres.username ]]
POSTGRES_PASSWORD=[[ .postgres.password ]]
EOF
      }
    }
  }
}
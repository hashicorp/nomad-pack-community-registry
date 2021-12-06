job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .postgres.datacenters | toPrettyJson ]]
  group "postgres" {
    network {
      port "postgres" {
        to = 5432
      }
    }

    service {
      name = "postgres"
      port = "postgres"
      check {
        name     = "postgres_alive"
        port     = "postgres"
        type     = "tcp"
        interval = "5s"
        timeout  = "30s"
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
POSTGRES_DB=
POSTGRES_INITDB_ARGS=
POSTGRES_INITDB_WALDIR=
POSTGRES_HOST_AUTH_METHOD=
PGDATA=
EOF
      }
    }
  }
}
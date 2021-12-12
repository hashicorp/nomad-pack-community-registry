job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .boundary.datacenters | toPrettyJson ]]
  group "boundary" {
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

    task "boundary-database-init" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }
      driver = "docker"
      config {
        image   = "hashicorp/boundary"
        command = "database"
        args    = [
          "init",
          "-config",
          "/boundary/boundary.hcl"
        ]
[[- if ne .boundary.config_file "" ]]
        volumes = [ "local/boundary.hcl:/boundary/boundary.hcl" ]
[[- end ]]
        cap_add    = [ [[- if .boundary.docker_cap_add_ipc_lock ]]"IPC_LOCK"[[- end ]] ] 
        privileged = [[ .boundary.docker_privileged ]]
      }

      ##TODO: Optionally interpolate Postgres address via Consul service discovery/service mesh
      ##TODO: Optionally pull Postgres creds from Vault via DB secrets engine
      template {
        change_mode = "restart"
        destination = "secrets/config.env"
        env         = true
        data        = <<EOF
BOUNDARY_POSTGRES_URL=postgresql://[[ .boundary.postgres_username ]]:[[ .boundary.postgres_password ]]@[[ .boundary.postgres_address ]]/postgres?sslmode=disable
EOF
      }

[[- if ne .boundary.config_file "" ]]
      # Boundary config file
      template {
        change_mode = "restart"
        destination = "local/boundary.hcl"
        data        = <<EOH
[[ .boundary.config_file ]]
EOH
      }
[[- end ]]

    }

    task "boundary" {
      driver = "docker"
      config {
        image   = "hashicorp/boundary"
[[- if ne .boundary.config_file "" ]]
        volumes = [ "local/boundary.hcl:/boundary/boundary.hcl" ]
[[- end ]]
        ports = [
          "controller",
          "worker",
          "comm"
        ]
        cap_add    = [ [[- if .boundary.docker_cap_add_ipc_lock ]]"IPC_LOCK"[[- end ]] ] 
        privileged = [[ .boundary.docker_privileged ]]
      }

      resources {
        cpu    = [[ .boundary.resources.cpu ]]
        memory = [[ .boundary.resources.memory ]]
      }

      ##TODO: Optionally interpolate Postgres address via Consul service discovery/service mesh
      ##TODO: Optionally pull Postgres creds from Vault via DB secrets engine
      template {
        change_mode = "restart"
        destination = "secrets/config.env"
        env         = true
        data        = <<EOF
BOUNDARY_POSTGRES_URL=postgresql://[[ .boundary.postgres_username ]]:[[ .boundary.postgres_password ]]@[[ .boundary.postgres_address ]]/postgres?sslmode=disable
EOF
      }

[[- if ne .boundary.config_file "" ]]
      # Boundary config file
      template {
        change_mode = "restart"
        destination = "local/boundary.hcl"
        data        = <<EOH
[[ .boundary.config_file ]]
EOH
      }
[[- end ]]
    }
  }
}

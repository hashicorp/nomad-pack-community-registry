job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ var "datacenters" . | toPrettyJson ]]
  namespace   = [[ var "namespace" . | quote ]]

  type = "system"

  [[ if var "constraints" . ]][[ range $idx, $constraint := var "constraints" . ]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    value     = [[ $constraint.value | quote ]]
    [[- if ne $constraint.operator "" ]]
    operator  = [[ $constraint.operator | quote ]]
    [[- end ]]
  }
  [[- end ]][[- end ]]

  group "caddy" {
    count = 1

    # Using ephemeral_disk to store Caddy data.
    # The data directory must not be treated as a cache.
    # Caddy stores TLS certificates, private keys, OCSP staples, and other necessary information to the data directory.
    # The path to this directory is configured via `XDG_DATA_HOME` variable.
    ephemeral_disk {
      migrate = true
      size    = 300
      sticky  = true
    }

    network {
      port "admin" {
        static = [[ var "admin_port" . ]]
        to     = 2019
      }
      port "https" {
        static = [[ var "https_port" . ]]
        to     = 443
      }
      port "http" {
        static = [[ var "http_port" . ]]
        to     = 80
      }
    }

    service {
      name = "caddy-https"
      port = "https"
      [[ if var "https_healthcheck_path" . ]]
      check {
        type     = "http"
        protocol = "https"
        name     = "https_health"
        path     = [[ var "https_healthcheck_path" . | quote ]]
        interval = "20s"
        timeout  = "5s"

        check_restart {
          limit = 3
          grace = "90s"
          ignore_warnings = false
        }
      }
      [[- end]]
    }

    service {
      name = "caddy-http"
      port = "http"

      check {
        type     = "http"
        name     = "http_health"
        path     = [[ var "http_healthcheck_path" . | quote ]]
        interval = "20s"
        timeout  = "5s"

        check_restart {
          limit = 3
          grace = "90s"
          ignore_warnings = false
        }
      }
    }

    task "caddy" {
      driver = "docker"

      env {
        XDG_DATA_HOME = "${NOMAD_ALLOC_DIR}/data/"
      }

      config {
        image = "caddy:[[ var "version_tag" . ]]"
        ports = ["https", "http"]

        # Bind the config file to container.
        mount {
          type   = "bind"
          source = "configs"
          target = "/etc/caddy"
        }
      }

      [[- if ne (var "caddyfile" .) "" ]]
      template {
        data        = <<EOH
  [[ var "caddyfile" . ]]
  EOH
        destination = "configs/Caddyfile"
        # Caddy doesn't support reload via signals.
        # https://github.com/caddyserver/caddy/issues/3967
        change_mode = "restart"
      }
      [[- end ]]

      resources {
        cpu    = [[ var "resources.cpu" . ]]
        memory = [[ var "resources.memory" . ]]
      }
    }
  }
}

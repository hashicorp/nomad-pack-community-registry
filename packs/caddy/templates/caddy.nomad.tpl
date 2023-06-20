job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .caddy.datacenters | toPrettyJson ]]
  namespace   = [[ .caddy.namespace | quote ]]

  type = "system"

  [[ if .caddy.constraints ]][[ range $idx, $constraint := .caddy.constraints ]]
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
        static = [[ .caddy.admin_port ]]
        to     = 2019
      }
      port "https" {
        static = [[ .caddy.https_port ]]
        to     = 443
      }
      port "http" {
        static = [[ .caddy.http_port ]]
        to     = 80
      }
    }

    service {
      name = "caddy-https"
      port = "https"
      [[ if .caddy.https_healthcheck_path ]]
      check {
        type     = "http"
        protocol = "https"
        name     = "https_health"
        path     = [[ .caddy.https_healthcheck_path | quote ]]
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
        path     = [[ .caddy.http_healthcheck_path | quote ]]
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
        image = "caddy:[[ .caddy.version_tag ]]"
        ports = ["https", "http"]

        # Bind the config file to container.
        mount {
          type   = "bind"
          source = "configs"
          target = "/etc/caddy"
        }
      }

      [[- if ne .caddy.caddyfile "" ]]
      template {
        data        = <<EOH
  [[ .caddy.caddyfile ]]
  EOH
        destination = "configs/Caddyfile"
        # Caddy doesn't support reload via signals.
        # https://github.com/caddyserver/caddy/issues/3967
        change_mode = "restart"
      }
      [[- end ]]

      resources {
        cpu    = [[ .caddy.resources.cpu ]]
        memory = [[ .caddy.resources.memory ]]
      }
    }
  }
}

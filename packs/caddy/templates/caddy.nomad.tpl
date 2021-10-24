job [[ template "job_name" . ]] {
[[ template "region" . ]]
datacenters = [ [[ range $idx, $dc := .caddy.datacenters ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]
  namespace = [[ .caddy.namespace | quote ]]

  type = "system"

  // must have linux for network mode
  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

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
    }

    service {
      name = "caddy-http"
      port = "http"
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

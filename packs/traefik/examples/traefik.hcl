# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

job_name = "traefik"

traefik_task = {
  driver       = "docker"
  version      = "v2.6.1"
  network_mode = "host"
}

traefik_group_network = {
  mode = "host"

  ports = {
    http = 80
    api  = 8080
  }
}

traefik_task_services = [
  {
    service_name       = "traefik-dashboard"
    service_port_label = "http"
    service_tags = [
      "traefik.enable=true",
      "traefik.http.routers.dashboard.rule=Host(`traefik.localhost`)",
      "traefik.http.routers.dashboard.service=api@internal",
      "traefik.http.routers.dashboard.entrypoints=web",
    ]

    check_enabled  = true
    check_type     = "tcp"
    check_path     = ""
    check_interval = "10s"
    check_timeout  = "5s"
  },
]

traefik_task_app_config = <<EOF
[entryPoints]
    [entryPoints.web]
    address = ":80"

[api]
    dashboard = true
    insecure  = true

[log]
    level = "DEBUG"

# Enable Consul Catalog configuration backend.
[providers.consulCatalog]
    prefix           = "traefik"
    exposedByDefault = false

    [providers.consulCatalog.endpoint]
      address = "http://localhost:8500"
      scheme  = "http"
EOF

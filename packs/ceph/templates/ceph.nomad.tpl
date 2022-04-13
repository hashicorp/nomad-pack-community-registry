job "[[ .my.job_name ]]" {

  [[- template "location" . ]]

  group "ceph" {

    [[- template "constraints" . ]]

    network {
      # we can't configure networking in a way that will both satisfy the Ceph
      # monitor's requirement to know its own IP address *and* be routable
      # between containers, without either CNI or fixing
      # https://github.com/hashicorp/nomad/issues/9781
      #
      # So for now we'll use host networking to keep this demo understandable.
      # That also means the controller plugin will need to use host addresses.
      mode = "host"
    }

    service {
      name = "[[ .my.ceph_monitor_service_name ]]"
      port = [[ .my.ceph_monitor_port ]]
    }

    service {
      name = "[[ .my.ceph_dashboard_service_name ]]"
      port = [[ .my.ceph_dashboard_port ]]

      check {
        type           = "http"
        interval       = "5s"
        timeout        = "1s"
        path           = "/"
        initial_status = "warning"
      }
    }

    task "ceph" {
      driver = "docker"

      config {
        image        = "[[ .my.ceph_image ]]"
        args         = ["demo"]
        network_mode = "host"
        privileged   = true

        mount {
          type   = "bind"
          source = "local/ceph"
          target = "/etc/ceph"
        }
      }

      [[- template "resources" . ]]

      template {

        data = <<EOT
MON_IP={{ sockaddr "with $ifAddrs := GetDefaultInterfaces | include \"type\" \"IPv4\" | limit 1 -}}{{- range $ifAddrs -}}{{ attr \"address\" . }}{{ end }}{{ end " }}
CEPH_PUBLIC_NETWORK=0.0.0.0/0
CEPH_DEMO_UID=[[ .my.ceph_demo_uid ]]
CEPH_DEMO_BUCKET=[[ .my.ceph_demo_bucket ]]
EOT

        destination = "${NOMAD_TASK_DIR}/env"
        env         = true
      }

      template {

        data        = <<EOT
[[ template "config_file" . ]]
EOT

        destination = "${NOMAD_TASK_DIR}/ceph/ceph.conf"
      }
    }
  }
}

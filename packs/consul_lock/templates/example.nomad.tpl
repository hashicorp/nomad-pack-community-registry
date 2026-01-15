job "[[ .my.job_name ]]" {
  [[ template "location" . ]]
  group "group" {
    [[ template "constraints" . ]]

    network {
      mode = "bridge"
      port "[[ .my.application_port_name ]]" {
        to = [[ .my.application_port ]]
      }
    }

    service {
      port = "[[ .my.application_port_name ]]"
    }

    task "block_for_lock" {
      driver = "docker"

      lifecycle {
        hook = "prestart"
        sidecar = true
      }

      env {
        CONSUL_ADDR = "${attr.unique.network.ip-address}:8500"
        LEADER_KEY = "[[ .my.locker_key ]]"
      }

      config {
        image = "[[ .my.locker_image ]]"
        command = "/bin/sh"
        args = ["-c", "apk add bash curl jq; bash local/lock.bash"]
      }

      template {
        data = <<EOT
{{ base64Decode "[[ fileContents .my.locker_script_path | b64enc ]]" }}

EOT

        destination = "local/lock.bash"
      }

      resources {
        cpu    = 128
        memory = 64
      }
    }

    task "main" {
      driver = "docker"
      config {
        image = "[[ .my.application_image ]]"
        command = "/bin/sh"
        args    = ["local/wait.sh"]
        ports   = ["[[ .my.application_port_name ]]"]
      }

      [[ template "resources" . ]]

      template {
        data = <<EOT
while :
do
  [ -d "${NOMAD_ALLOC_DIR}/${NOMAD_ALLOC_ID}.lock" ] && break
  sleep 1
done

# the directory exists so we have the lock and can exec into the
# main application
exec [[ .my.application_args ]]

EOT
        destination = "local/wait.sh"
      }

      template {
        data        = "<html>hello from {{ env \"NOMAD_ALLOC_ID\" }}</html>"
        destination = "local/index.html"
      }


    }
  }
}

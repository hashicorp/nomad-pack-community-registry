job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .kibana.datacenters | toJson ]]
  node_pool = [[ .kibana.node_pool | quote ]]
  type = "service"
  [[- if .kibana.namespace ]]
  namespace   = [[ .kibana.namespace | quote ]]
  [[- end]]
  [[- if .kibana.constraints ]][[ range $idx, $constraint := .kibana.constraints ]]
  constraint {
    [[- if ne $constraint.attribute "" ]]
    attribute = [[ $constraint.attribute | quote ]]
    [[- end ]]
    [[- if ne $constraint.value "" ]]
    value     = [[ $constraint.value | quote ]]
    [[- end ]]
    [[- if ne $constraint.operator "" ]]
    operator  = [[ $constraint.operator | quote ]]
    [[- end ]]
  }
  [[- end ]]
  [[- end ]]

  group [[ template "job_name" . ]] {
    count = 1

    network {
      port "http" {
        to = 5601
      }
    }

    [[- if .kibana.register_consul_service ]]
    service {
      name = "[[ .kibana.consul_service_name ]]"
      [[if ne (len .kibana.consul_service_tags) 0 ]]
      tags = [[ .kibana.consul_service_tags | toJson ]]
      [[ end ]]
      port = "http"

      check {
        name     = "alive"
        type     = "http"
        path     = "/api/status"
        interval = "10s"
        timeout  = "2s"
      }
    }
    [[- end ]]

    [[- if .kibana.config_volume_name ]]
    volume "[[.kibana.config_volume_name]]" {
      type      = "[[.kibana.config_volume_type]]"
      read_only = false
      source    = "[[.kibana.config_volume_name]]"
    }
    [[- end]]

    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    [[- if .kibana.config_volume_name ]]
    task "chown_config_volume" {
        lifecycle {
            hook = "prestart"
            sidecar = false
        }

        volume_mount {
          volume      = "[[ .kibana.config_volume_name ]]"
          destination = "/usr/share/kibana/config"
          read_only   = false
        }

        driver = "docker"
        user = "root"
        config {
            image   = "busybox:stable"
            command = "sh"
            args    = ["-c", "chown -R 1000:1000 /usr/share/kibana/config"]
        }

        resources {
            cpu    = 200
            memory = 128
        }
    }
    [[- end]]

    [[- if .kibana.kibana_config_file_path ]]
    task "config_file_persist" {
        lifecycle {
            hook = "prestart"
            sidecar = false
        }

        volume_mount {
          volume      = "[[ .kibana.config_volume_name ]]"
          destination = "/usr/share/kibana/config"
          read_only   = false
        }

        driver = "docker"
        user = "root"
        config {
            image   = "busybox:stable"
            command = "sh"
            args    = ["-c", "cp local/kibana.yml /usr/share/kibana/config/kibana.yml"]
        }

        template {
          data = <<EOH
[[ fileContents .kibana.kibana_config_file_path ]]
EOH
          destination = "local/kibana.yml"
        }

        resources {
            cpu    = 200
            memory = 128
        }
    }
    [[- end]]

    [[- if and .kibana.kibana_keystore_name .kibana.config_volume_name ]]
    task "kibana_keystore_persist" {
        lifecycle {
            hook = "poststart"
            sidecar = false
        }

        volume_mount {
          volume      = "[[ .kibana.config_volume_name ]]"
          destination = "/usr/share/kibana/config"
          read_only   = false
        }

        driver = "docker"
        config {
          image   = "[[ .kibana.image_name ]]:[[ .kibana.image_tag ]]"
          command = "/bin/bash"
          args    = ["-c", "bin/kibana-keystore create && bin/kibana-keystore add [[.kibana.kibana_keystore_name]]"]
        }

        resources {
          cpu    = 200
          memory = 128
        }
    }
    [[- end]]

    task [[ template "job_name" . ]] {
      driver = "docker"

      [[- if .kibana.config_volume_name ]]
      volume_mount {
        volume      = "[[ .kibana.config_volume_name ]]"
        destination = "/usr/share/kibana/config"
        read_only   = false
      }
      [[- end]]

      config {
        image = "[[ .kibana.image_name ]]:[[ .kibana.image_tag ]]"
        ports = ["http"]
        [[- if and .kibana.config_volume_name .kibana.kibana_config_file_path]]
        volumes = [
          "local/kibana.yml:/usr/share/kibana/config/kibana.yml",
        ]
        [[- end]]
      }

      [[- if ne (len .kibana.kibana_config_file_path) 0]]
        template {
          data = <<EOH
[[ fileContents .kibana.kibana_config_file_path ]]
EOH
          destination = "local/kibana.yml"
        }
      [[- end]]

      [[- if ne (len .kibana.docker_kibana_env_vars) 0 ]]
      env {
        [[ range $key, $var := .kibana.docker_kibana_env_vars ]]
        [[if ne (len $var) 0 ]][[ $key | upper ]] = [[ $var | quote ]][[ end ]]
        [[ end ]]
      }
      [[- end ]]
      resources {
        cpu    = [[ .kibana.task_resources.cpu ]]
        memory = [[ .kibana.task_resources.memory ]]
      }
    }
  }
}

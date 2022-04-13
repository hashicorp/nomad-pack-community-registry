job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .influxdb.datacenters | toStringList ]]
  type = "service"
  [[- if .influxdb.namespace ]]
  namespace   = [[ .influxdb.namespace | quote ]]
  [[- end]]
  [[- if .influxdb.constraints ]][[ range $idx, $constraint := .influxdb.constraints ]]
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
        to = 8086
      }
    }

    [[- if .influxdb.register_consul_service ]]
    service {
      name = "[[ .influxdb.consul_service_name ]]"
      [[if ne (len .influxdb.consul_service_tags) 0 ]]
      tags = [ [[ range $idx, $tag := .influxdb.consul_service_tags ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]
      [[ end ]]
      port = "http"

      check {
        name     = "alive"
        type     = "http"
        path     = "/health"
        interval = "10s"
        timeout  = "2s"
      }
    }
    [[- end ]]

    [[- if .influxdb.config_volume_name ]]
    volume "[[.influxdb.config_volume_name]]" {
      type      = "[[.influxdb.config_volume_type]]"
      read_only = false
      source    = "[[.influxdb.config_volume_name]]"
    }
    [[- end]]

    [[- if .influxdb.data_volume_name ]]
    volume "[[.influxdb.data_volume_name]]" {
      type      = "[[.influxdb.data_volume_type]]"
      read_only = false
      source    = "[[.influxdb.data_volume_name]]"
    }
    [[- end]]

    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    [[- if .influxdb.data_volume_name ]]
    task "chown_data_volume" {
        lifecycle {
            hook = "prestart"
            sidecar = false
        }

        volume_mount {
          volume      = "[[ .influxdb.data_volume_name ]]"
          destination = "/var/lib/influxdb2"
          read_only   = false
        }

        driver = "docker"
        config {
          image   = "busybox:stable"
          command = "sh"
          args    = ["-c", "chown -R 1000:1000 /var/lib/influxdb2"]
        }

        resources {
          cpu    = 200
          memory = 128
        }
    }
    [[- end]]

    [[- if .influxdb.config_volume_name ]]
    task "chown_config_volume" {
        lifecycle {
            hook = "prestart"
            sidecar = false
        }

        volume_mount {
          volume      = "[[ .influxdb.config_volume_name ]]"
          destination = "/etc/influxdb2"
          read_only   = false
        }

        driver = "docker"
        user = "root"
        config {
            image   = "busybox:stable"
            command = "sh"
            args    = ["-c", "chown -R 1000:1000 /etc/influxdb2"]
        }

        resources {
            cpu    = 200
            memory = 128
        }
    }
    [[- end]]

    task [[ template "job_name" . ]] {
      driver = "docker"

      [[- if .influxdb.data_volume_name ]]
      volume_mount {
        volume      = "[[ .influxdb.data_volume_name ]]"
        destination = "/var/lib/influxdb2"
        read_only   = false
      }
      [[- end]]

      [[- if .influxdb.config_volume_name ]]
      volume_mount {
        volume      = "[[ .influxdb.config_volume_name ]]"
        destination = "/etc/influxdb2"
        read_only   = false
      }
      [[- end]]

      config {
        image = "[[ .influxdb.image_name ]]:[[ .influxdb.image_tag ]]"
        ports = ["http"]
      }
      [[- if ne (len .influxdb.docker_influxdb_env_vars) 0 ]]
      env {
        [[ range $key, $var := .influxdb.docker_influxdb_env_vars ]]
        [[if ne (len $var) 0 ]][[ $key | upper ]] = [[ $var | quote ]][[ end ]]
        [[ end ]]
      }
      [[- end ]]
      resources {
        cpu    = [[ .influxdb.task_resources.cpu ]]
        memory = [[ .influxdb.task_resources.memory ]]
      }
    }
  }
}

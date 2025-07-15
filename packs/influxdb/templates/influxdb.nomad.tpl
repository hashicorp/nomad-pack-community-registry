job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ var "datacenters" . | toStringList ]]
  node_pool   = [[ var "node_pool" . | quote ]]
  [[- if var "namespace" . ]]
  namespace   = [[ var "namespace" . | quote ]]
  [[- end]]
  [[- if var "constraints" . ]][[ range $idx, $constraint := var "constraints" . ]]
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

    [[- if var "register_consul_service" . ]]
    service {
      name = "[[ var "consul_service_name" . ]]"
      [[if ne (len (var "consul_service_tags" .)) 0 ]]
      tags = [ [[ range $idx, $tag := var "consul_service_tags" . ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]
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

    [[- if var "config_volume_name" . ]]
    volume "[[var "config_volume_name" .]]" {
      type      = "[[var "config_volume_type" .]]"
      read_only = false
      source    = "[[var "config_volume_name" .]]"
    }
    [[- end]]

    [[- if var "data_volume_name" . ]]
    volume "[[var "data_volume_name" .]]" {
      type      = "[[var "data_volume_type" .]]"
      read_only = false
      source    = "[[var "data_volume_name" .]]"
    }
    [[- end]]

    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    [[- if var "data_volume_name" . ]]
    task "chown_data_volume" {
        lifecycle {
            hook = "prestart"
            sidecar = false
        }

        volume_mount {
          volume      = "[[ var "data_volume_name" . ]]"
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

    [[- if var "config_volume_name" . ]]
    task "chown_config_volume" {
        lifecycle {
            hook = "prestart"
            sidecar = false
        }

        volume_mount {
          volume      = "[[ var "config_volume_name" . ]]"
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

      [[- if var "data_volume_name" . ]]
      volume_mount {
        volume      = "[[ var "data_volume_name" . ]]"
        destination = "/var/lib/influxdb2"
        read_only   = false
      }
      [[- end]]

      [[- if var "config_volume_name" . ]]
      volume_mount {
        volume      = "[[ var "config_volume_name" . ]]"
        destination = "/etc/influxdb2"
        read_only   = false
      }
      [[- end]]

      config {
        image = "[[ var "image_name" . ]]:[[ var "image_tag" . ]]"
        ports = ["http"]
      }
      [[- if ne (len (var "docker_influxdb_env_vars" .)) 0 ]]
      env {
        [[ range $key, $var := var "docker_influxdb_env_vars" . ]]
        [[if ne (len $var) 0 ]][[ $key | upper ]] = [[ $var | quote ]][[ end ]]
        [[ end ]]
      }
      [[- end ]]
      resources {
        cpu    = [[ var "task_resources.cpu" . ]]
        memory = [[ var "task_resources.memory" . ]]
      }
    }
  }
}

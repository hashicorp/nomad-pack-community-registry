job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [ [[ range $idx, $dc := .influxdb.datacenters ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]
  type = "service"
  [[ if .influxdb.namespace ]]
  namespace   = [[ .influxdb.namespace | quote ]]
  [[end]]
  [[ if .influxdb.constraints ]][[ range $idx, $constraint := .influxdb.constraints ]]
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

    [[ if .influxdb.register_consul_service ]]
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
    [[ end ]]

    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task [[ template "job_name" . ]] {
      driver = "docker"

      config {
        image = "[[ .influxdb.image_name ]]:[[ .influxdb.image_tag ]]"
        ports = ["http"]
      }
      [[if ne (len .influxdb.docker_influxdb_env_vars) 0 ]]
      env {
        [[ range $key, $var := .influxdb.docker_influxdb_env_vars ]]
        [[if ne (len $var) 0 ]][[ $key | upper ]] = [[ $var | quote ]][[ end ]]
        [[ end ]]
      }
      [[ end ]]
      resources {
        cpu    = [[ .influxdb.influxdb_task_resources.cpu ]]
        memory = [[ .influxdb.influxdb_task_resources.memory ]]
      }
    }
  }
}

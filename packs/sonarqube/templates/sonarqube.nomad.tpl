job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ .sonarqube.datacenters | toStringList ]]
  type = "service"
  [[- if .sonarqube.namespace ]]
  namespace   = [[ .sonarqube.namespace | quote ]]
  [[- end ]]
  [[- if .sonarqube.constraints ]][[ range $idx, $constraint := .sonarqube.constraints ]]
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
        to  = 9000
      }
    }
  
    [[- if .sonarqube.register_consul_service ]]
    service {
      name = "[[ .sonarqube.consul_service_name ]]"
      [[- if ne (len .sonarqube.consul_service_tags) 0 ]]
      tags = [[ .sonarqube.consul_service_tags | toStringList ]]
      [[- end ]]
      port = "http"
      check {
        name     = "alive"
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }
    }
    [[- end ]]

    [[- if .sonarqube.volume_name ]]
    volume "[[.sonarqube.volume_name]]" {
      type      = "[[.sonarqube.volume_type]]"
      read_only = false
      source    = "[[.sonarqube.volume_name]]"
    }
    [[- end ]]

    restart {
      attempts = 2
      interval = "5m"
      delay    = "15s"
      mode     = "fail"
    }

    task [[ template "job_name" . ]] {
      driver = "docker"

      [[- if .sonarqube.volume_name ]]
      volume_mount {
        volume      = "[[ .sonarqube.volume_name ]]"
        destination = "/opt/sonarqube/data"
        read_only   = false
      }
      [[- end ]]

      config {
        image = "[[ .sonarqube.image_name ]]:[[ .sonarqube.image_tag ]]"
        ports = ["http"]
      }

      [[if ne (len .sonarqube.sonarqube_env_vars) 0 ]]
      env {
        [[ range $key, $var := .sonarqube.sonarqube_env_vars ]]
        [[if ne (len $var) 0 ]][[ $key | upper ]] = [[ $var | quote ]][[ end ]]
        [[ end ]]
      }
      [[ end ]]

      resources {
        cpu    = [[ .sonarqube.task_resources.cpu ]]
        memory = [[ .sonarqube.task_resources.memory ]]
      }
    }
  }
}
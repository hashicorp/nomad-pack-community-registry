job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [[ var "datacenters" . | toStringList ]]
  type = "service"
  [[- if var "namespace" . ]]
  namespace   = [[ var "namespace" . | quote ]]
  [[- end ]]
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
        to  = 9000
      }
    }
  
    [[- if var "register_consul_service" . ]]
    service {
      name = "[[ var "consul_service_name" . ]]"
      [[- if ne (len (var "consul_service_tags" .)) 0 ]]
      tags = [[ var "consul_service_tags" . | toStringList ]]
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

    [[- if var "volume_name" . ]]
    volume "[[var "volume_name" .]]" {
      type      = "[[var "volume_type" .]]"
      read_only = false
      source    = "[[var "volume_name" .]]"
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

      [[- if var "volume_name" . ]]
      volume_mount {
        volume      = "[[ var "volume_name" . ]]"
        destination = "/opt/sonarqube/data"
        read_only   = false
      }
      [[- end ]]

      config {
        image = "[[ var "image_name" . ]]:[[ var "image_tag" . ]]"
        ports = ["http"]
      }

      [[if ne (len (var "sonarqube_env_vars" .)) 0 ]]
      env {
        [[ range $key, $var := var "sonarqube_env_vars" . ]]
        [[if ne (len $var) 0 ]][[ $key | upper ]] = [[ $var | quote ]][[ end ]]
        [[ end ]]
      }
      [[ end ]]

      resources {
        cpu    = [[ var "task_resources.cpu" . ]]
        memory = [[ var "task_resources.memory" . ]]
      }
    }
  }
}
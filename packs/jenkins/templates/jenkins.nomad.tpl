job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [ [[ range $idx, $dc := .jenkins.datacenters ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]
  type = "service"
  [[ if .jenkins.namespace ]]
  namespace   = [[ .jenkins.namespace | quote ]]
  [[end]]
  [[ if .jenkins.constraints ]][[ range $idx, $constraint := .jenkins.constraints ]]
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
        to = 8080
      }
      port "jnlp" {
        to = 50000
      }
    }

    [[ if .jenkins.register_consul_service ]]
    service {
      name = "[[ .jenkins.consul_service_name ]]"
      [[if ne (len .jenkins.consul_service_tags) 0 ]]
      tags = [ [[ range $idx, $tag := .jenkins.consul_service_tags ]][[if $idx]],[[end]][[ $tag | quote ]][[ end ]] ]
      [[ end ]]
      port = "http"

      check {
        name     = "alive"
        type     = "http"
        path     = "/login"
        interval = "10s"
        timeout  = "2s"
      }
    }
    [[ end ]]

    [[ if .jenkins.volume_name ]]
    volume "[[.jenkins.volume_name]]" {
      type      = "[[.jenkins.volume_type]]"
      read_only = false
      source    = "[[.jenkins.volume_name]]"
    }
    [[end]]

    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    [[ if .jenkins.volume_name ]]
    task "chown" {
        lifecycle {
            hook = "prestart"
        }

        volume_mount {
          volume      = "[[ .jenkins.volume_name ]]"
          destination = "/var/jenkins_home"
          read_only   = false
        }

        driver = "exec"
        user = "root"
        config = {
            command = "chown"
            args = ["-R", "1000:1000", "/var/jenkins_home"]
        }
    }
    [[end]]

    task [[ template "job_name" . ]] {
      driver = "docker"

      [[ if .jenkins.volume_name ]]
      volume_mount {
        volume      = "[[ .jenkins.volume_name ]]"
        destination = "/var/jenkins_home"
        read_only   = false
      }
      [[end]]

      config {
        image = "[[ .jenkins.image_name ]]:[[ .jenkins.image_tag ]]"
        ports = ["http","jnlp"]
      }
      [[if ne (len .jenkins.docker_jenkins_env_vars) 0 ]]
      env {
        [[ range $key, $var := .jenkins.docker_jenkins_env_vars ]]
        [[if ne (len $var) 0 ]][[ $key | upper ]] = [[ $var | quote ]][[ end ]]
        [[ end ]]
      }
      [[ end ]]
      resources {
        cpu    = [[ .jenkins.task_resources.cpu ]]
        memory = [[ .jenkins.task_resources.memory ]]
      }
    }
  }
}

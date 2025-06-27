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
        to = 8080
      }
      port "jnlp" {
        to = 50000
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
        path     = "/login"
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
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    [[- if var "volume_name" . ]]
    task "chown" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      volume_mount {
        volume      = "[[ var "volume_name" . ]]"
        destination = "/var/jenkins_home"
        read_only   = false
      }

      driver = "docker"

      config {
        image   = "busybox:stable"
        command = "sh"
        args    = ["-c", "chown -R 1000:1000 /var/jenkins_home"]
      }

      resources {
        cpu    = 200
        memory = 128
      }
    }
    [[- end ]]

    [[- if var "plugins" . ]]
    task "install-plugins" {
      driver = "docker"
      volume_mount {
        volume      = "[[ var "volume_name" . ]]"
        destination = "/var/jenkins_home"
        read_only   = false
      }
      config {
        image   = "[[ var "image_name" . ]]:[[ var "image_tag" . ]]"
        command = "jenkins-plugin-cli"
        args    = ["-f", "/var/jenkins_home/plugins.txt", "--plugin-download-directory", "/var/jenkins_home/plugins/"]
        volumes = [
          "local/plugins.txt:/var/jenkins_home/plugins.txt",
        ]
      }
    
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      template {
        data = <<EOF
[[ range $plugin := var "plugins" . ]][[ $plugin]]
[[ end ]]
EOF
        destination   = "local/plugins.txt"
        change_mode   = "noop"
      }

      resources {
        cpu    = [[ var "task_resources.cpu" . ]]
        memory = [[ var "task_resources.memory" . ]]
      }
    }
    [[- end ]]

    task [[ template "job_name" . ]] {
      driver = "docker"

      [[- if var "volume_name" . ]]
      volume_mount {
        volume      = "[[ var "volume_name" . ]]"
        destination = "/var/jenkins_home"
        read_only   = false
      }
      [[- end ]]

      config {
        image = "[[ var "image_name" . ]]:[[ var "image_tag" . ]]"
        ports = ["http","jnlp"]
        [[- if var "jasc_config" . ]]
        volumes = [
          "local/jasc.yaml:/var/jenkins_home/jenkins.yaml",
        ]
        [[ end ]]
      }
      [[if ne (len (var "docker_jenkins_env_vars" .)) 0 ]]
      env {
        [[ range $key, $var := var "docker_jenkins_env_vars" . ]]
        [[if ne (len $var) 0 ]][[ $key | upper ]] = [[ $var | quote ]][[ end ]]
        [[ end ]]
      }
      [[ end ]]

      [[- if var "jasc_config" .]]
      template {
        data = <<EOF
[[ var "jasc_config" . ]]
EOF
        change_mode   = "noop"
        destination   = "local/jasc.yaml"
      }
      [[ end ]]

      resources {
        cpu    = [[ var "task_resources.cpu" . ]]
        memory = [[ var "task_resources.memory" . ]]
      }
    }
  }
}

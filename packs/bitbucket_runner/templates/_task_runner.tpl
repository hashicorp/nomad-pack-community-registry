[[- define "task_runner" -]]
task "runner" {
  driver = "docker"

  resources {
    cpu    = [[ .bitbucket_runner.task_resources.cpu ]]
    memory = [[ .bitbucket_runner.task_resources.memory ]]
    memory_max = [[ .bitbucket_runner.task_resources.memory_max ]]
  }

  [[- if .bitbucket_runner.task_environment ]]

  template {
    destination = "${NOMAD_SECRETS_DIR}/env"
    env = true
    data = <<-HEREDOC
    [[- range $key, $value := .bitbucket_runner.task_environment ]]
    [[ $key ]]=[[ $value | quote ]]
    [[- end ]]
    HEREDOC
  }
  
  [[- end ]]

  config {
    image = "[[ .bitbucket_runner.container_image.name ]]:[[ .bitbucket_runner.container_image.version ]]"
    
    [[- if .bitbucket_runner.task_mounts ]][[ range $idx, $mount := .bitbucket_runner.task_mounts ]]
    
    mount {
      type = [[ $mount.type | quote ]]
      target = [[ $mount.target | quote ]]
      source = [[ $mount.source | quote ]]
      readonly = [[ $mount.readonly ]]
    }

    [[- end ]][[ end ]]
  }

  [[- if .bitbucket_runner.task_services ]][[ range $idx, $service := .bitbucket_runner.task_services ]]
  
  service {
    name = [[ $service.service_name | quote ]]
    port = [[ $service.service_port ]]

    [[- if $service.check_enabled ]]

    check {
      type     = [[ $service.check_type | quote ]]
      path     = [[ $service.check_path | quote ]]
      interval = [[ $service.check_interval | quote ]]
      timeout  = [[ $service.check_timeout | quote ]]
    }
    [[- end ]]
  }
  [[- end ]][[ end ]]
} # TASK
[[- end -]]

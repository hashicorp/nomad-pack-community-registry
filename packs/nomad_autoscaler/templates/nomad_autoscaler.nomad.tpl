job [[ template "full_job_name" . ]] {

  region      = [[ var "region" . | quote ]]
  datacenters = [[ var "datacenters" . | toStringList ]]
  namespace   = [[ var "namespace" . | quote ]]

  group "autoscaler" {

    network {
      port [[ var "autoscaler_agent_network.autoscaler_http_port_label" . | quote ]] {
        to = 8080
      }
    }

    task "autoscaler_agent" {
      driver = [[ var "autoscaler_agent_task.driver" . | quote ]]

      [[- if ( eq (var "autoscaler_agent_task.driver" .) "exec" ) ]]
      artifact {
        source      = [[ printf "\"https://releases.hashicorp.com/nomad-autoscaler/:%s/nomad-autoscaler_%s_linux_amd64.zip\"" (var "autoscaler_agent_task.version" .) var "autoscaler_agent_task.version" . ]]
        destination = "/usr/local/bin"
      }
      [[- end ]]

      config {
      [[- if ( eq (var "autoscaler_agent_task.driver" .) "docker" ) ]]
        image   = [[ printf "\"hashicorp/nomad-autoscaler:%s\"" (var "autoscaler_agent_task.version" .) ]]
        command = "nomad-autoscaler"
        ports   = [ [[ var "autoscaler_agent_network.autoscaler_http_port_label" . | quote ]] ]
      [[- end ]]
      [[- if ( eq (var "autoscaler_agent_task.driver" .) "exec" ) ]]
        command = "/usr/local/bin/nomad-autoscaler"
      [[- end ]]
        args    = [[ template "full_args" . ]]
      }

      [[- if var "autoscaler_agent_task.config_files" . ]]
      [[ range $idx, $file := var "autoscaler_agent_task.config_files" . ]]
      template {
        data = <<EOF
[[ fileContents $file ]]
        EOF

        destination = [[ printf "\"${NOMAD_TASK_DIR}/config/%s\"" ( base $file ) ]]
      }
      [[ end ]]
      [[- end ]]

      [[- if var "autoscaler_agent_task.scaling_policy_files" . ]]
      [[ range $idx, $file := var "autoscaler_agent_task.scaling_policy_files" . ]]
      template {
        data = <<EOF
[[ fileContents $file ]]
        EOF

        destination = [[ printf "\"${NOMAD_TASK_DIR}/policies/%s\"" ( base $file ) ]]
      }
      [[ end ]]
      [[- end ]]

      resources {
        cpu    = [[ var "autoscaler_agent_task_resources.cpu" . ]]
        memory = [[ var "autoscaler_agent_task_resources.memory" . ]]
      }

      [[- if var "autoscaler_agent_task_service.enabled" . ]]
      service {
        name = [[ var "autoscaler_agent_task_service.service_name" . | quote ]]
        port = [[ var "autoscaler_agent_network.autoscaler_http_port_label" . | quote ]]
        tags = [[ var "autoscaler_agent_task_service.service_tags" . | toStringList ]]

        check {
          type     = [[ var "autoscaler_agent_network.autoscaler_http_port_label" . | quote ]]
          path     = "/v1/health"
          interval = [[ var "autoscaler_agent_task_service.check_interval" . | quote ]]
          timeout  = [[ var "autoscaler_agent_task_service.check_timeout" . | quote ]]
        }
      }
      [[- end ]]
    }
  }
}

job [[ template "full_job_name" . ]] {

  region      = [[ .nomad_autoscaler.region | quote ]]
  datacenters = [[ .nomad_autoscaler.datacenters | toPrettyJson ]]
  namespace   = [[ .nomad_autoscaler.namespace | quote ]]

  group "autoscaler" {

    network {
      port [[ .nomad_autoscaler.autoscaler_agent_network.autoscaler_http_port_label | quote ]] {
        to = 8080
      }
    }

    task "autoscaler_agent" {
      driver = [[ .nomad_autoscaler.autoscaler_agent_task.driver | quote ]]

      [[- if ( eq .nomad_autoscaler.autoscaler_agent_task.driver "exec" ) ]]
      artifact {
        source      = [[ printf "\"https://releases.hashicorp.com/nomad-autoscaler/:%s/nomad-autoscaler_%s_linux_amd64.zip\"" .nomad_autoscaler.autoscaler_agent_task.version .nomad_autoscaler.autoscaler_agent_task.version ]]
        destination = "/usr/local/bin"
      }
      [[- end ]]

      config {
      [[- if ( eq .nomad_autoscaler.autoscaler_agent_task.driver "docker" ) ]]
        image   = [[ printf "\"hashicorp/nomad-autoscaler:%s\"" .nomad_autoscaler.autoscaler_agent_task.version ]]
        command = "nomad-autoscaler"
        ports   = [ [[ .nomad_autoscaler.autoscaler_agent_network.autoscaler_http_port_label | quote ]] ]
      [[- end ]]
      [[- if ( eq .nomad_autoscaler.autoscaler_agent_task.driver "exec" ) ]]
        command = "/usr/local/bin/nomad-autoscaler"
      [[- end ]]
        args    = [[ template "full_args" . ]]
      }

      [[- if .nomad_autoscaler.autoscaler_agent_task.config_files ]]
      [[ range $idx, $file := .nomad_autoscaler.autoscaler_agent_task.config_files ]]
      template {
        data = <<EOF
[[ fileContents $file ]]
        EOF

        destination = [[ printf "\"${NOMAD_TASK_DIR}/config/%s\"" ( base $file ) ]]
      }
      [[ end ]]
      [[- end ]]

      [[- if .nomad_autoscaler.autoscaler_agent_task.scaling_policy_files ]]
      [[ range $idx, $file := .nomad_autoscaler.autoscaler_agent_task.scaling_policy_files ]]
      template {
        data = <<EOF
[[ fileContents $file ]]
        EOF

        destination = [[ printf "\"${NOMAD_TASK_DIR}/policies/%s\"" ( base $file ) ]]
      }
      [[ end ]]
      [[- end ]]

      resources {
        cpu    = [[ .nomad_autoscaler.autoscaler_agent_task_resources.cpu ]]
        memory = [[ .nomad_autoscaler.autoscaler_agent_task_resources.memory ]]
      }

      [[- if .nomad_autoscaler.autoscaler_agent_task_service.enabled ]]
      service {
        name = [[ .nomad_autoscaler.autoscaler_agent_task_service.service_name | quote ]]
        port = [[ .nomad_autoscaler.autoscaler_agent_network.autoscaler_http_port_label | quote ]]
        tags = [[ .nomad_autoscaler.autoscaler_agent_task_service.service_tags | toPrettyJson ]]

        check {
          type     = [[ .nomad_autoscaler.autoscaler_agent_network.autoscaler_http_port_label | quote ]]
          path     = "/v1/health"
          interval = [[ .nomad_autoscaler.autoscaler_agent_task_service.check_interval | quote ]]
          timeout  = [[ .nomad_autoscaler.autoscaler_agent_task_service.check_timeout | quote ]]
        }
      }
      [[- end ]]
    }
  }
}

job [[ template "job_name" . ]] {

  region      = [[ var "region" . | quote]]
  datacenters = [[ var "datacenters" . | toStringList ]]
  type        = "system"
  namespace   = [[ var "namespace" . | quote]]
  [[ if var "constraints" . ]][[ range $idx, $constraint := var "constraints" . ]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    value     = [[ $constraint.value | quote ]]
    [[- if ne $constraint.operator "" ]]
    operator  = [[ $constraint.operator | quote ]]
    [[- end ]]
  }
  [[- end ]][[- end ]]

  group "fabio" {

    network {
      mode = [[ var "fabio_group_network.mode" . | quote ]]
      [[- range $label, $to := var "fabio_group_network.ports" . ]]
      port [[ $label | quote ]] {
        static = [[ $to ]]
      }
      [[- end ]]
    }

    task "fabio" {
      driver = "docker"
      config {
        image = "fabiolb/fabio:[[ var "fabio_task_config.version" . ]]"
        [[- if var "fabio_group_network.ports" . ]]
        [[- $ports := keys (var "fabio_group_network.ports" .) ]]
        ports = [[ $ports | toPrettyJson ]]
        [[- end ]]

        [[- if ne (var "fabio_task_app_properties" .) "" ]]
        volumes = [
            "local/fabio.properties:/etc/fabio/fabio.properties",
        ]
        [[- end ]]
      }

      [[- if ne (var "fabio_task_app_properties" .) "" ]]
       template {
         data = <<EOF
[[ var "fabio_task_app_properties" . ]]
EOF

         destination = "local/fabio.properties"
       }
       [[- end ]]

      resources {
        cpu    = [[ var "fabio_task_resources.cpu" . ]]
        memory = [[ var "fabio_task_resources.memory" . ]]
      }
    }
  }
}

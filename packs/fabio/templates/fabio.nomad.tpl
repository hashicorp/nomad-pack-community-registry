job [[ template "job_name" . ]] {

  region      = [[ .fabio.region | quote]]
  datacenters = [[ .fabio.datacenters | toStringList ]]
  type        = "system"
  namespace   = [[ .fabio.namespace | quote]]
  [[ if .fabio.constraints ]][[ range $idx, $constraint := .fabio.constraints ]]
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
      mode = [[ .fabio.fabio_group_network.mode | quote ]]
      [[- range $label, $to := .fabio.fabio_group_network.ports ]]
      port [[ $label | quote ]] {
        static = [[ $to ]]
      }
      [[- end ]]
    }

    task "fabio" {
      driver = "docker"
      config {
        image = "fabiolb/fabio:[[ .fabio.fabio_task_config.version ]]"
        [[- if .fabio.fabio_group_network.ports ]]
        [[- $ports := keys .fabio.fabio_group_network.ports ]]
        ports = [[ $ports | toStringList ]]
        [[- end ]]

        [[- if ne .fabio.fabio_task_app_properties "" ]]
        volumes = [
            "local/fabio.properties:/etc/fabio/fabio.properties",
        ]
        [[- end ]]
      }

      [[- if ne .fabio.fabio_task_app_properties "" ]]
       template {
         data = <<EOF
[[ .fabio.fabio_task_app_properties ]]
EOF

         destination = "local/fabio.properties"
       }
       [[- end ]]

      resources {
        cpu    = [[ .fabio.fabio_task_resources.cpu ]]
        memory = [[ .fabio.fabio_task_resources.memory ]]
      }
    }
  }
}

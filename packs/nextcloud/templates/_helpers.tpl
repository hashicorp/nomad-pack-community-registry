// allow nomad-pack to set the job name

[[ define "job_name" ]]
[[- if eq (var "job_name" .) "" -]]
[[- meta "pack.name" . | quote -]]
[[- else -]]
[[- var "job_name" . | quote -]]
[[- end ]]
[[- end ]]

// only deploys to a region if specified

[[ define "region" -]]
[[- if not (eq (var "region" .) "") -]]
  region = [[ var "region" . | quote]]
[[- end -]]
[[- end -]]

[[ define "constraints" -]]
[[ range $idx, $constraint := . ]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    [[ if $constraint.operator -]]
    operator  = [[ $constraint.operator | quote ]]
    [[ end -]]
    value     = [[ $constraint.value | quote ]]
  }
[[ end -]]
[[- end -]]

// Generic "service" block template
[[ define "service" -]]
[[ $service := . ]]
      service {
        name = [[ $service.service_name | quote ]]
        port = [[ $service.service_port_label | quote ]]
        tags = [[ $service.service_tags | toJson ]]
        [[- if gt (len $service.upstreams) 0 ]]
        connect {
          sidecar_service {
            proxy {
              [[- if gt (len $service.upstreams) 0 ]]
              [[- range $upstream := $service.upstreams ]]
              upstreams {
                destination_name = [[ $upstream.name | quote ]]
                local_bind_port  = [[ $upstream.port ]]
              }
              [[- end ]]
              [[- end ]]
            }
          }
        }
        [[- end ]]
        check {
          type     = [[ $service.check_type | quote ]]
          [[- if $service.check_path]]
          path     = [[ $service.check_path | quote ]]
          [[- end]]
          interval = [[ $service.check_interval | quote ]]
          timeout  = [[ $service.check_timeout | quote ]]
        }
      }
[[- end ]]

[[ define "env_vars" -]]
        [[- range $idx, $var := . ]]
        [[ $var.key ]] = [[ $var.value | quote ]]
        [[- end ]]
[[- end ]]

[[ define "mounts" -]]
[[- range $idx, $mount := . ]]
        mount {
          type = [[ $mount.type | quote ]]
          target = [[ $mount.target | quote ]]
          source = [[ $mount.source | quote ]]
          readonly = [[ $mount.readonly ]]
          [[- if gt (len $mount.bind_options) 0 ]]
          bind_options {
            [[- range $idx, $opt := $mount.bind_options ]]
            [[ $opt.name ]] = [[ $opt.value | quote ]]
            [[- end ]]
          }
          [[- end ]]
        }
[[- end ]]
[[- end ]]

[[ define "resources" -]]
[[- $resources := . ]]
      resources {
        cpu    = [[ $resources.cpu ]]
        memory = [[ $resources.memory ]]
      }
[[- end ]]

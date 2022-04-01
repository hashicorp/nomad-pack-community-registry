// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .redis.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .redis.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .redis.region "") -]]
region = [[ .redis.region | quote]]
[[- end -]]
[[- end -]]

[[- define "constraints" -]]
[[- range $idx, $constraint := . ]]
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    [[ if $constraint.operator -]]
    operator  = [[ $constraint.operator | quote ]]
    [[ end -]]
    value     = [[ $constraint.value | quote ]]
  }
[[- end ]]
[[- end -]]

// Generic "service" block template
[[- define "service" -]]
[[- if .redis.redis_task_services ]]
[[- range $idx, $service := .redis.redis_task_services ]]
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
        type     = "http"
        path     = [[ $service.check_path | quote ]]
        interval = [[ $service.check_interval | quote ]]
        timeout  = [[ $service.check_timeout | quote ]]
      }
    }
[[- end ]]
[[- end ]]
[[- end -]]

[[- define "env" -]]
      env {
        [[- range $idx, $var := . ]]
        [[ $var.name | quote ]] = [[ $var.value | quote ]]
        [[- end ]]
      }
[[- end -]]

[[- define "group_network" -]]
    network {
      mode = [[ .redis.redis_group_network.mode | quote ]]
      [[- range $label, $to := .redis.redis_group_network.ports ]]
      port [[ $label | quote ]] {
        to = [[ $to ]]
      }
      [[- end ]]
    }
[[- end -]]

[[- define "redis_task_args" -]]
[[- if gt (len .redis.redis_task_args) 0 ]]
args = [[ .redis.redis_task_args | toJson ]]
[[- end -]]
[[- end -]]
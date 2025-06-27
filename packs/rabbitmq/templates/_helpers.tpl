// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq (var "job_name" .) "" -]]
[[- meta "pack.name" . | quote -]]
[[- else -]]
[[- var "job_name" . | quote -]]
[[- end -]]
[[- end -]]


// if additional plugins are defined, return this:
//    "[rabbitmq_peer_discovery_consul,rabbitmq_management]."
// if nothing is defined, return only consul:
//    "[rabbitmq_peer_discovery_consul]."
[[- define "rabbit_plugins" ]]
  [[- if var "enabled_plugins" . -]]
    "[rabbitmq_peer_discovery_consul,
    [[- range $index, $name := var "enabled_plugins" . -]]
      [[if $index]],[[end]][[ $name ]]
    [[- end -]]
    ]."
  [[- else -]]
    "[rabbitmq_peer_discovery_consul]."
  [[- end -]]
[[- end -]]


[[- define "port" ]]
  [[- if . ]]
        static = [[ . ]]
  [[- end -]]
[[- end -]]

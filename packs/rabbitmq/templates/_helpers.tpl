// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .rabbitmq.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .rabbitmq.job_name | quote -]]
[[- end -]]
[[- end -]]


// if additional plugins are defined, return this:
//    "[rabbitmq_peer_discovery_consul,rabbitmq_management]."
// if nothing is defined, return only consul:
//    "[rabbitmq_peer_discovery_consul]."
[[- define "rabbit_plugins" ]]
  [[- if .enabled_plugins -]]
    "[rabbitmq_peer_discovery_consul,
    [[- range $index, $name := .enabled_plugins -]]
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

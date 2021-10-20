// allow nomad-pack to set the job name

[[- define "job_name" -]]
[[- if eq .caasperli.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .caasperli.job_name | quote -]]
[[- end -]]
[[- end -]]

// only deploys to a region if specified

[[- define "region" -]]
[[- if not (eq .caasperli.region "") -]]
region = [[ .caasperli.region | quote]]
[[- end -]]
[[- end -]]

// expose app service on static port if static_port is defined

[[- define "network" -]]
[[- if not (eq .caasperli.static_port -1) -]]
    network {
      port "http" {
        to = 8080
        static = [[ .caasperli.static_port ]]
      }
    }
[[- end -]]
[[- end -]]

[[- define "ports" -]]
[[- if not (eq .caasperli.static_port -1) -]]
        ports = ["http"]
[[- end -]]
[[- end -]]

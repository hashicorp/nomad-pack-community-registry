[[- define "group_network" -]]
    network {
[[- if eq (var "network_mode" .) "bridge" ]]
      mode = "bridge"
[[- end ]]
      port "http" {
        to = [[ var "server.port" . ]]
        [[- if and (eq (var "load_balancer_mode" .) "none") (gt (var "http_port_static" .) 0) ]]
        static = [[ var "http_port_static" . ]]
        [[- end ]]
      }
      port "grpc" {
        to = [[ add (var "server.port" .) 1 ]]
      }
      port "serf" {
        to = [[ var "serf.port" . ]]
        [[- if gt (var "serf_port_static" .) 0 ]]
        static = [[ var "serf_port_static" . ]]
        [[- end ]]
      }
[[- if and (eq (var "database_mode" .) "provision") (eq (var "count" .) 1) ]]
      port "db" {
        to = 5432
      }
[[- end ]]
    }
[[- end -]]

[[- define "postgres_group_network" -]]
    network {
[[- if eq (var "network_mode" .) "bridge" ]]
      mode = "bridge"
[[- end ]]
      port "db" {
        to = 5432
        [[- if gt (var "postgres.host_port" .) 0 ]]
        static = [[ var "postgres.host_port" . ]]
        [[- end ]]
      }
    }
[[- end -]]

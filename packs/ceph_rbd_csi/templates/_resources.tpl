[[- define "resources" ]]
      resources {
        cpu    = [[ var "resources.cpu" . ]]
        memory = [[ var "resources.memory" . ]]
      }
[[- end -]]
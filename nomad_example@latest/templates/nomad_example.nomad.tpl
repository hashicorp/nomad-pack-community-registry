job [[ template "job_name" . ]] {
  [[ template "region" . ]]

  datacenters = [ [[ range $idx, $dc := .nomad_example.datacenters ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]

  [[ template "nomad_example.metadata" . ]]

  group "cache" {
    network {
      port [[ .nomad_example.cache_redis_task.port_6379_label | quote ]] {
        to = 6379
      }
    }

    task "redis" {
      driver = "docker"

      config {
        image = [[ printf "\"redis:%s\"" .nomad_example.cache_redis_task.image_version ]]
        ports = [ [[ .nomad_example.cache_redis_task.port_6379_label | quote ]] ]
      }

      resources {
        cpu    = [[ .nomad_example.cache_redis_resources.cpu ]]
        memory = [[ .nomad_example.cache_redis_resources.memory ]]
      }
    }
  }
}

job [[ template "job_name" . ]] {

  [[ template "region" . ]]
  datacenters = [[ .redis.datacenters | toJson ]]
  namespace   = [[ .redis.namespace | quote ]]
  type        = "service"
  
  [[- if gt (len .redis.constraints) 0 ]] 
  [[ template "constraints" .redis.constraints ]]
  [[- end ]]

  group "[[ .redis.redis_group_name ]]" {
    count = [[ .redis.server_count ]]
    [[ template "group_network" . ]]
    [[ template "service" . ]]

    task "redis" {
      driver = "docker"  
      config {
        image = "redis:[[ .redis.version_tag ]]"
        ports = [[ keys .redis.redis_group_network.ports | toJson ]]
        [[ template "redis_task_args" . ]]
      }
      resources {
        cpu    = [[ .redis.resources.cpu ]]
        memory = [[ .redis.resources.memory ]]
      }
    }
  }
}

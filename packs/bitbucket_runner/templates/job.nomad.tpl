job "[[ template "job_name" . ]]" {
  namespace = [[ .bitbucket_runner.namespace | quote ]]
  type = "service"
  
  region = [[ .bitbucket_runner.region | quote ]]
  datacenters = [
  [[- range $idx, $datacenter := .bitbucket_runner.datacenters ]]
    [[ $datacenter | quote ]],
  [[- end ]]
  ]

  priority = [[ .bitbucket_runner.priority ]]
  
  [[- if .bitbucket_runner.constraints ]][[ range $idx, $constraint := .bitbucket_runner.constraints ]]
  
  constraint {
    attribute = [[ $constraint.attribute | quote ]]
    value     = [[ $constraint.value | quote ]]
    
    [[- if ne $constraint.operator "" ]]
    operator  = [[ $constraint.operator | quote ]]
    [[- end ]]
  }
  [[- end ]][[- end ]]
  
[[/*
=================================================
GROUP CONFIGURATION
=================================================
*/ -]]

group "runner" {
  count = [[ .bitbucket_runner.instances ]]
  
  network {
    mode = [[ .bitbucket_runner.network_mode | quote ]]
  }

[[/*
=================================================
INCLUDE TASK TEMPLATE(S)
=================================================
*/ -]]
[[ template "task_runner" . ]]

} # GROUP
} # JOB

job [[ template "job_name" . ]] {
  [[ template "region" . ]]
  datacenters = [ [[ range $idx, $dc := .caasperli.datacenters ]][[if $idx]],[[end]][[ $dc | quote ]][[ end ]] ]
  type = "service"

  group "app" {
    count = [[ .caasperli.count ]]

    [[ template "network" . ]]

    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "server" {
      driver = "docker"

      config {
        image = "ghcr.io/adfinis-sygroup/potz-holzoepfel-und-zipfelchape"
        [[ template "ports" . ]]
      }
    }
  }
}

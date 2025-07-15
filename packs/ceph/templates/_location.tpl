[[- define "location" ]]
  namespace   = "[[ .my.namespace ]]"
  region      = "[[ .my.region ]]"
  datacenters = [[ .my.datacenters | toJson ]]
  node_pool = [[ var "node_pool" . | quote ]]
[[- end -]]
